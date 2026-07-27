// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import Foundation
import SwiftUI
import Vision

@Observable
class CowsGameViewModel {
    // MARK: - Propriedades de Estado do Jogo
    var score: Int = 0
    var lives: Int = 3
    let maxLives: Int = 3
    var gameState: GameState = .ready
    var activeAbductions: [AbductionTarget] = []
    
    // MARK: - Hand Tracking & Debug Visual
    var currentHandPoints: [CGPoint] = []
    var drawingPathPoints: [CGPoint] = []
    var isPinchingActive: Bool = false
    var lastDetectedGesture: GesturePrediction? = nil
    var allProbabilities: [String: Double] = [:]
    var feedbackMessage: String? = nil
    
    // MARK: - Dependências & Buffers (Vision + CoreML)
    let visionService: VisionService
    private var coreMLService = CoreMLService.shared
    
    private let windowSize = 60
    private var observationBuffer: [VNHumanHandPoseObservation] = []
    private var currentPinchBuffer: [VNHumanHandPoseObservation] = []
    private var wasPinching: Bool = false
    private var framesWithoutHand = 0
    private var predictionFrameCounter = 0
    
    // Callbacks para sincronização com a SpriteKit Scene
    var onRescueTriggered: ((UUID) -> Void)?
    var onAbductTriggered: ((UUID) -> Void)?
    var onStartGameTriggered: (() -> Void)?
    
    private var feedbackTimer: Timer?
    
    init(visionService: VisionService = VisionService()) {
        self.visionService = visionService
        setupCallbacks()
    }
    
    // MARK: - Fluxo Principal do Jogo
    func startGame() {
        score = 0
        lives = maxLives
        gameState = .playing
        activeAbductions.removeAll()
        lastDetectedGesture = nil
        allProbabilities.removeAll()
        drawingPathPoints.removeAll()
        currentPinchBuffer.removeAll()
        wasPinching = false
        feedbackMessage = nil
        
        visionService.start()
        onStartGameTriggered?()
    }
    
    func stopGame() {
        gameState = .gameOver
        visionService.stop()
        observationBuffer.removeAll()
        currentPinchBuffer.removeAll()
        drawingPathPoints.removeAll()
        currentHandPoints.removeAll()
    }
    
    func restartGame() {
        startGame()
    }
    
    // MARK: - Callbacks de Visão & Ingestão Contínua
    private func setupCallbacks() {
        visionService.onObservation = { [weak self] observation in
            guard let self = self, self.gameState == .playing else { return }
            
            var isPinching = false
            
            // 1. Extração da pinça (ThumbTip & IndexTip encostados)
            if let indexPoint = try? observation.recognizedPoint(.indexTip),
               let thumbPoint = try? observation.recognizedPoint(.thumbTip),
               indexPoint.confidence > 0.4, thumbPoint.confidence > 0.4 {
                
                let dx = thumbPoint.location.x - indexPoint.location.x
                let dy = thumbPoint.location.y - indexPoint.location.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // Exige que os dedos encostem (< 0.045)
                isPinching = distance < 0.045
                
                DispatchQueue.main.async {
                    self.isPinchingActive = isPinching
                    if isPinching {
                        // Inverte X e Y para espelhamento perfeito igual ao FallingOrbs
                        let mirroredPoint = CGPoint(x: 1.0 - indexPoint.location.x, y: 1.0 - indexPoint.location.y)
                        self.drawingPathPoints.append(mirroredPoint)
                        if self.drawingPathPoints.count > 60 {
                            self.drawingPathPoints.removeFirst()
                        }
                    } else {
                        // Soltou a pinça -> Limpa o traçado
                        if !self.drawingPathPoints.isEmpty {
                            self.drawingPathPoints.removeAll()
                        }
                    }
                }
            }
            
            // 2. Buffer da Pinça e Disparo Instantâneo ao Soltar
            if isPinching {
                self.currentPinchBuffer.append(observation)
            } else {
                if self.wasPinching && self.currentPinchBuffer.count >= 6 {
                    let stretched = self.resampleToWindowSize(self.currentPinchBuffer, targetSize: self.windowSize)
                    self.analyzeBuffer(stretched)
                }
                self.currentPinchBuffer.removeAll()
            }
            self.wasPinching = isPinching
            
            // 3. Esqueleto da Mão (Pontos para a UI)
            if let allPoints = try? observation.recognizedPoints(.all) {
                var points: [CGPoint] = []
                for (_, point) in allPoints {
                    if point.confidence > 0.3 {
                        points.append(CGPoint(x: 1.0 - point.location.x, y: 1.0 - point.location.y))
                    }
                }
                DispatchQueue.main.async {
                    self.currentHandPoints = points
                }
            }
            
            self.framesWithoutHand = 0
            self.observationBuffer.append(observation)
            
            if self.observationBuffer.count > self.windowSize {
                self.observationBuffer.removeFirst()
            }
            
            // 4. Predição contínua fluída em background
            if self.observationBuffer.count == self.windowSize {
                self.predictionFrameCounter += 1
                if self.predictionFrameCounter >= 3 {
                    self.predictionFrameCounter = 0
                    self.analyzeBuffer(self.observationBuffer)
                }
            }
        }
        
        visionService.onHandLost = { [weak self] in
            guard let self = self else { return }
            self.framesWithoutHand += 1
            if self.framesWithoutHand > 30 {
                self.observationBuffer.removeAll()
                self.currentPinchBuffer.removeAll()
                self.wasPinching = false
                DispatchQueue.main.async {
                    self.currentHandPoints.removeAll()
                    self.drawingPathPoints.removeAll()
                    self.isPinchingActive = false
                }
            }
        }
    }
    
    /// Redimensiona um buffer de N frames para exatamente 60 frames
    private func resampleToWindowSize(_ buffer: [VNHumanHandPoseObservation], targetSize: Int = 60) -> [VNHumanHandPoseObservation] {
        guard !buffer.isEmpty else { return [] }
        if buffer.count == targetSize { return buffer }
        
        var resampled: [VNHumanHandPoseObservation] = []
        let sourceCount = buffer.count
        
        for i in 0..<targetSize {
            let fraction = Double(i) / Double(targetSize - 1)
            let sourceIndex = Int(round(fraction * Double(sourceCount - 1)))
            let safeIndex = min(max(sourceIndex, 0), sourceCount - 1)
            resampled.append(buffer[safeIndex])
        }
        
        return resampled
    }
    
    private func thresholdForGesture(_ gesture: String) -> Double {
        switch gesture {
        case "Triangle": return 0.35
        case "Infinite": return 0.40
        default: return 0.45
        }
    }
    
    private func analyzeBuffer(_ buffer: [VNHumanHandPoseObservation]) {
        do {
            if let result = try coreMLService.predict(observations: buffer) {
                DispatchQueue.main.async {
                    self.lastDetectedGesture = result
                    self.allProbabilities = result.allProbabilities
                    
                    let requiredThreshold = self.thresholdForGesture(result.label)
                    
                    if result.confidence >= requiredThreshold {
                        self.handleGestureRecognized(result)
                    }
                }
            }
        } catch {
            print("Erro no CoreML predict: \(error)")
        }
    }
    
    // MARK: - Processamento de Resgate
    func handleGestureRecognized(_ prediction: GesturePrediction) {
        guard gameState == .playing else { return }
        
        // Converte a label prevista pelo CoreML para GestureType
        guard let matchedType = GestureType(rawValue: prediction.label) else { return }
        
        if let targetIndex = activeAbductions.firstIndex(where: { $0.gestureRequired == matchedType && !$0.isRescued && !$0.isAbducted }) {
            let target = activeAbductions[targetIndex]
            activeAbductions[targetIndex].isRescued = true
            
            onRescueTriggered?(target.id)
            
            score += 100
            showFeedback("Vaca Resgatada! 🎉 +100 pts")
        }
    }
    
    // MARK: - Eventos de Abdução e Vidas
    func registerAbduction(_ target: AbductionTarget) {
        activeAbductions.append(target)
    }
    
    func onCowAbducted(targetId: UUID) {
        guard gameState == .playing else { return }
        
        if let index = activeAbductions.firstIndex(where: { $0.id == targetId }) {
            activeAbductions[index].isAbducted = true
        }
        
        lives = max(0, lives - 1)
        showFeedback("Vaca Abduzida! 🛸 -1 Vida")
        
        if lives <= 0 {
            gameState = .gameOver
        }
    }
    
    func onCowRescued(targetId: UUID) {
        activeAbductions.removeAll(where: { $0.id == targetId })
    }
    
    private func showFeedback(_ text: String) {
        feedbackMessage = text
        feedbackTimer?.invalidate()
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.feedbackMessage = nil
        }
    }
}
