import AVFoundation
import Vision
import CoreImage

class VisionService: NSObject {
    let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // Callback para emitir o gesto detectado e a posição normalizada do pulso (para o cursor)
    var onHandDetected: ((HandGesture, CGPoint) -> Void)?
    
    private lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        
        // No macOS, a câmera embutida
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("Câmera não encontrada")
            captureSession.commitConfiguration()
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            print("Não foi possível adicionar o input de vídeo")
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            
            let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
            videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        } else {
            print("Não foi possível adicionar o output de vídeo")
        }
        
        captureSession.commitConfiguration()
    }
    
    func start() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stop() {
        captureSession.stopRunning()
    }
}

extension VisionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else {
                return // Nenhuma mão detectada
            }
            
            processObservation(observation)
        } catch {
            print("Erro ao processar VNHumanHandPoseRequest: \(error)")
        }
    }
    
    private func processObservation(_ observation: VNHumanHandPoseObservation) {
        do {
            let wristPoint = try observation.recognizedPoint(.wrist)
            let indexTip = try observation.recognizedPoint(.indexTip)
            let middleTip = try observation.recognizedPoint(.middleTip)
            
            // Garantir que a confiança da detecção é alta o suficiente
            guard wristPoint.confidence > 0.3,
                  indexTip.confidence > 0.3,
                  middleTip.confidence > 0.3 else { return }
            
            let wristLocation = wristPoint.location
            let indexLocation = indexTip.location
            let middleLocation = middleTip.location
            
            // Calcular distâncias dos dedos em relação ao pulso
            let indexDistance = hypot(indexLocation.x - wristLocation.x, indexLocation.y - wristLocation.y)
            let middleDistance = hypot(middleLocation.x - wristLocation.x, middleLocation.y - wristLocation.y)
            
            let avgDistance = (indexDistance + middleDistance) / 2
            
            // Heurística simples
            let gesture: HandGesture
            if avgDistance > 0.25 {
                gesture = .openHand // Dedos longe do pulso
            } else if avgDistance < 0.12 {
                gesture = .fist // Dedos próximos ao pulso
            } else {
                gesture = .unknown
            }
            
            // A coordenada do Vision tem a origem (0,0) no canto inferior esquerdo.
            // Para UI no macOS/iOS, geralmente a origem é no canto superior esquerdo. Invertemos o Y.
            let normalizedLocation = CGPoint(x: wristLocation.x, y: 1.0 - wristLocation.y)
            
            DispatchQueue.main.async { [weak self] in
                self?.onHandDetected?(gesture, normalizedLocation)
            }
        } catch {
            // Pontos não reconhecidos
        }
    }
}
