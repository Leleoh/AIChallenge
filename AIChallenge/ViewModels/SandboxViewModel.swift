import SwiftUI
import Vision

@Observable
class SandboxViewModel {
    var state: DrawingState = .idle
    var drawnPoints: [CGPoint] = []
    var prediction: GesturePrediction?
    
    // CoreML input limit
    private let maxFrames = 60
    private var observationBuffer: [VNHumanHandPoseObservation] = []
    
    // Dependencies
    var visionService: VisionService
    private var coreMLService = CoreMLService.shared
    
    init(visionService: VisionService) {
        self.visionService = visionService
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        visionService.onPinchStateChanged = { [weak self] isPinching, location in
            guard let self = self else { return }
            
            if isPinching {
                if self.state == .idle || self.state == .analyzing {
                    self.startDrawing(at: location)
                } else if self.state == .drawing {
                    self.continueDrawing(at: location)
                }
            } else {
                if self.state == .drawing {
                    self.finishDrawing()
                }
            }
        }
        
        visionService.onObservationBuffered = { [weak self] observation in
            guard let self = self else { return }
            if self.state == .drawing {
                self.observationBuffer.append(observation)
                
                if self.observationBuffer.count >= self.maxFrames {
                    self.finishDrawing()
                }
            }
        }
    }
    
    func start() {
        visionService.start()
    }
    
    func stop() {
        visionService.stop()
        state = .idle
        drawnPoints.removeAll()
        observationBuffer.removeAll()
    }
    
    private func startDrawing(at point: CGPoint) {
        state = .drawing
        drawnPoints = [point]
        observationBuffer.removeAll()
        prediction = nil
    }
    
    private func continueDrawing(at point: CGPoint) {
        drawnPoints.append(point)
    }
    
    private func finishDrawing() {
        guard state == .drawing else { return }
        state = .analyzing
        
        // Pass the buffer to Core ML
        if let result = coreMLService.predict(observations: observationBuffer) {
            self.prediction = result
        }
        
        self.observationBuffer.removeAll()
        self.state = .idle 
    }
}
