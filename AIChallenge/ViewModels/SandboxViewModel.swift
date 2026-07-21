import SwiftUI
import Vision

@Observable
class SandboxViewModel {
    var prediction: GesturePrediction?
    var errorMessage: String?
    var currentHandPoints: [CGPoint] = []
    
    // Variável para tolerância a falhas
    private var framesWithoutHand = 0
    
    // Lista de gestos disponíveis que o modelo conhece
    let availableGestures = ["V", "Infinite", "Triangle", "Circle", "Z", "Square"]
    var targetGesture: String = ""
    var hasWon: Bool = false
    
    // Sliding Window
    private let windowSize = 60
    var observationBuffer: [VNHumanHandPoseObservation] = []
    
    // Dependencies
    var visionService: VisionService
    private var coreMLService = CoreMLService.shared
    
    // Evita rodar predição em todo único frame para economizar bateria (Ex: rodar a cada 5 frames)
    private var frameCounter = 0
    private let predictionInterval = 5
    
    init(visionService: VisionService) {
        self.visionService = visionService
        setupCallbacks()
        pickNewTarget()
    }
    
    func pickNewTarget() {
        targetGesture = availableGestures.randomElement() ?? "Circle"
        prediction = nil
        observationBuffer.removeAll()
        hasWon = false
    }
    
    private func setupCallbacks() {
        visionService.onObservation = { [weak self] observation in
            guard let self = self else { return }
            
            // Extrair pontos para debug visual (Skeleton)
            if let allPoints = try? observation.recognizedPoints(.all) {
                var points: [CGPoint] = []
                for (_, point) in allPoints {
                    if point.confidence > 0.3 {
                        // O preview da câmera no Mac geralmente espelha a imagem. 
                        // Vamos usar x: 1.0 - x se estiver desalinhado, mas primeiro testamos x natural.
                        points.append(CGPoint(x: point.location.x, y: 1.0 - point.location.y))
                    }
                }
                // Como onObservation pode vir de background thread, forçamos a atualização da UI na main thread
                DispatchQueue.main.async {
                    self.currentHandPoints = points
                }
            }
            
            self.framesWithoutHand = 0 // Resetar tolerância pois vimos a mão!
            
            // Adiciona a nova observação na janela deslizante
            self.observationBuffer.append(observation)
            if self.observationBuffer.count > self.windowSize {
                self.observationBuffer.removeFirst()
            }
            
            // Começa a prever somente quando a janela estiver cheia (exatos 60 frames = 2 segundos).
            // Adivinhar o gesto antes dele terminar (com padding) pode confundir o modelo com gestos que começam parecidos.
            if self.observationBuffer.count == self.windowSize {
                self.frameCounter += 1
                if self.frameCounter >= self.predictionInterval {
                    self.frameCounter = 0
                    self.analyzeWindow()
                }
            }
        }
        
        visionService.onHandLost = { [weak self] in
            guard let self = self else { return }
            self.framesWithoutHand += 1
            
            // Se perdermos a mão por 30 frames (1 segundo), limpamos o buffer
            if self.framesWithoutHand > 30 {
                self.observationBuffer.removeAll()
                self.frameCounter = 0
                self.prediction = nil
                self.currentHandPoints.removeAll()
            }
        }
    }
    
    func start() {
        visionService.start()
    }
    
    func stop() {
        visionService.stop()
        observationBuffer.removeAll()
    }
    
    private func analyzeWindow() {
        if hasWon { return } // Congela a IA quando acertar
        
        // Passa a janela inteira pro CoreML
        do {
            if let result = try coreMLService.predict(observations: observationBuffer) {
                self.prediction = result
                self.errorMessage = nil
                
                if result.label == targetGesture && result.confidence > 0.6 {
                    self.hasWon = true
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
