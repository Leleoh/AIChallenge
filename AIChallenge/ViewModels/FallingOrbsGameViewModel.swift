// Ref: docs/sdd/FallingOrbs_GameLoop_Spec.md
import SwiftUI
import Vision
import Combine

@Observable
class FallingOrbsGameViewModel {
    // Game State Properties
    var orbs: [FallingOrb] = []
    var score: Int = 0
    var lives: Int = 3
    var gameState: GameState = .ready
    
    // Speed Control
    var currentSpeed: Double = 0.05 // Incremento de Posição Y por segundo
    let minSpeed: Double = 0.05
    let maxSpeed: Double = 0.22 // Cap máximo para ergonomia
      // Feedback / Visual Debug
    var currentHandPoints: [CGPoint] = []
    var drawingPathPoints: [CGPoint] = [] // Histórico de pontos da ponta do dedo para o traçado visual
    var lastRecognizedGesture: String = ""
    var gestureConfidence: Double = 0.0
    var allProbabilities: [String: Double] = [:] // Top probabilidades para a UI de debug
    var isPinchingActive: Bool = false
    
    // Dependencies & Buffer (Vision + CoreML)
    var visionService: VisionService
    private var coreMLService = CoreMLService.shared
    
    private let windowSize = 60
    private var observationBuffer: [VNHumanHandPoseObservation] = []
    private var currentPinchBuffer: [VNHumanHandPoseObservation] = []
    private var wasPinching: Bool = false
    private var framesWithoutHand = 0
    private var predictionFrameCounter = 0
    
    // Timers
    private var gameLoopTimer: Timer?
    private var spawnTimer: Timer?
    
    init(visionService: VisionService) {
        self.visionService = visionService
        setupCallbacks()
    }
    
    func startGame() {
        orbs.removeAll()
        score = 0
        lives = 3
        currentSpeed = minSpeed
        lastRecognizedGesture = ""
        gestureConfidence = 0.0
        allProbabilities.removeAll()
        drawingPathPoints.removeAll()
        currentPinchBuffer.removeAll()
        wasPinching = false
        gameState = .playing
        
        visionService.start()
        startTimers()
    }
    
    func stopGame() {
        gameState = .gameOver
        stopTimers()
        visionService.stop()
        observationBuffer.removeAll()
        currentPinchBuffer.removeAll()
        drawingPathPoints.removeAll()
        orbs.removeAll()
    }
    
    private func startTimers() {
        stopTimers()
        
        // Loop de física (~60fps = 0.016s)
        gameLoopTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGameLoop(deltaTime: 0.016)
        }
        
        // Timer de Spawn a cada 2.5 segundos
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            self?.spawnOrb()
        }
    }
    
    private func stopTimers() {
        gameLoopTimer?.invalidate()
        gameLoopTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    private func spawnOrb() {
        guard gameState == .playing else { return }
        
        guard let gesture = GestureType.allCases.randomElement() else { return }
        let randomX = Double.random(in: 0.15...0.85) // Evita surgir colado nas margens laterais
        
        let newOrb = FallingOrb(positionY: 0.0, positionX: randomX, targetGesture: gesture)
        orbs.append(newOrb)
    }
    
    func updateGameLoop(deltaTime: Double) {
        guard gameState == .playing else { return }
        
        var indicesToRemove: [Int] = []
        
        for i in 0..<orbs.count {
            orbs[i].positionY += currentSpeed * deltaTime
            
            // Se o orb atingir o chão (1.0)
            if orbs[i].positionY >= 1.0 {
                indicesToRemove.append(i)
                lives -= 1
            }
        }
        
        // Remove os orbs que atingiram o chão
        for index in indicesToRemove.reversed() {
            if index < orbs.count {
                orbs.remove(at: index)
            }
        }
        
        // Condição de Game Over
        if lives <= 0 {
            lives = 0
            stopGame()
        }
    }
    
    func onGestureRecognized(_ gestureLabel: String) {
        guard gameState == .playing else { return }
        
        // Filtra todos os orbs que correspondem ao gesto reconhecido
        let matchingOrbs = orbs.filter { $0.targetGesture.rawValue == gestureLabel }
        
        if !matchingOrbs.isEmpty {
            // Destrói TODOS os orbs correspondentes presentes na tela
            orbs.removeAll { $0.targetGesture.rawValue == gestureLabel }
            
            let pointsGained = matchingOrbs.count * 100
            score += pointsGained
            
            // Aumenta a velocidade de queda progressivamente até o limite máximo
            if currentSpeed < maxSpeed {
                currentSpeed = min(maxSpeed, currentSpeed + 0.005)
            }
        }
    }
    
    private func setupCallbacks() {
        visionService.onObservation = { [weak self] observation in
            guard let self = self, self.gameState == .playing else { return }
            
            var isPinching = false
            
            // Extração da pinça (Pinch: distância entre polegar e indicador para o traçado visual)
            if let indexPoint = try? observation.recognizedPoint(.indexTip),
               let thumbPoint = try? observation.recognizedPoint(.thumbTip),
               indexPoint.confidence > 0.4, thumbPoint.confidence > 0.4 {
                
                let dx = thumbPoint.location.x - indexPoint.location.x
                let dy = thumbPoint.location.y - indexPoint.location.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // Reduzido para 0.045: exige que os dedos realmente encostem para contar como Pinça!
                isPinching = distance < 0.045
                
                DispatchQueue.main.async {
                    self.isPinchingActive = isPinching
                    if isPinching {
                        let mirroredPoint = CGPoint(x: 1.0 - indexPoint.location.x, y: 1.0 - indexPoint.location.y)
                        self.drawingPathPoints.append(mirroredPoint)
                        if self.drawingPathPoints.count > 60 {
                            self.drawingPathPoints.removeFirst()
                        }
                    } else {
                        // Ao abrir a mão / soltar a pinça, limpa o traçado da tela!
                        if !self.drawingPathPoints.isEmpty {
                            self.drawingPathPoints.removeAll()
                        }
                    }
                }
            }
            
            // Grava os frames EXATOS do desenho durante o pinch
            if isPinching {
                self.currentPinchBuffer.append(observation)
            } else {
                // INSTANTÂNEO (0ms delay): No segundo que o usuário solta a pinça, processa o desenho esticado!
                if self.wasPinching && self.currentPinchBuffer.count >= 6 {
                    let stretched = self.resampleToWindowSize(self.currentPinchBuffer, targetSize: self.windowSize)
                    self.analyzeBuffer(stretched)
                }
                self.currentPinchBuffer.removeAll()
            }
            self.wasPinching = isPinching
            
            // Extração do esqueleto da mão (debug visual espelhado para a UI)
            if let allPoints = try? observation.recognizedPoints(.all) {
                var points: [CGPoint] = []
                for (_, point) in allPoints {
                    if point.confidence > 0.3 {
                        // Inverte X (1.0 - x) para acompanhar o espelhamento da câmera na tela
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
            
            // Predição contínua fluída em background
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
    
    /// Redimensiona/estica um buffer de tamanho N (ex: 15 frames rápidos) para exatamente 60 frames
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
    
    /// Retorna o limiar de confiança necessário para aceitar cada gesto
    private func thresholdForGesture(_ gesture: String) -> Double {
        switch gesture {
        case "Triangle": return 0.35 // Limiar super acessível para o Triângulo
        case "Infinite": return 0.40
        default: return 0.45
        }
    }
    
    private func analyzeBuffer(_ buffer: [VNHumanHandPoseObservation]) {
        do {
            if let result = try coreMLService.predict(observations: buffer) {
                DispatchQueue.main.async {
                    self.lastRecognizedGesture = result.label
                    self.gestureConfidence = result.confidence
                    self.allProbabilities = result.allProbabilities
                    
                    let requiredThreshold = self.thresholdForGesture(result.label)
                    
                    // Se a confiança atingir o limiar do gesto, aciona o estouro do orb
                    if result.confidence >= requiredThreshold {
                        self.onGestureRecognized(result.label)
                    }
                }
            }
        } catch {
            print("Erro no CoreML predict: \(error)")
        }
    }
}
