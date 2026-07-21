import AVFoundation
import Vision
import CoreImage

class VisionService: NSObject {
    let captureSession = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // Callback para emitir o gesto detectado, a posição normalizada do pulso, e a lista de todos os pontos
    var onHandDetected: ((HandGesture, CGPoint, [CGPoint]) -> Void)?
    
    // Callbacks para o CoreML Sandbox (Desenho de Trajetórias)
    var onPinchStateChanged: ((Bool, CGPoint) -> Void)?
    var onObservationBuffered: ((VNHumanHandPoseObservation) -> Void)?
    
    private lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    override init() {
        super.init()
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        
        // No macOS, a câmera embutida
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("⚠️ Câmera não encontrada. Você habilitou o Entitlement de Câmera no App Sandbox?")
            captureSession.commitConfiguration()
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            print("⚠️ Não foi possível adicionar o input de vídeo. Verifique as permissões.")
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
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            self.startSession()
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startSession()
                } else {
                    print("⚠️ Permissão de câmera negada pelo usuário.")
                }
            }
        } else {
            print("⚠️ Câmera sem permissão ou restrita. Vá nas Preferências do Sistema para liberar.")
        }
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Precisamos configurar a câmera apenas quando temos permissão
            if self.captureSession.inputs.isEmpty {
                self.setupCamera()
            }
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
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
            // Pegar todos os pontos para renderizar na tela
            let allPoints = try observation.recognizedPoints(.all)
            var detectedPoints: [CGPoint] = []
            
            for (_, point) in allPoints {
                if point.confidence > 0.3 {
                    // Inverte o Y porque a coordenada do Vision tem (0,0) no canto inferior esquerdo
                    detectedPoints.append(CGPoint(x: point.location.x, y: 1.0 - point.location.y))
                }
            }
            
            let wristPoint = try observation.recognizedPoint(.wrist)
            let indexTip = try observation.recognizedPoint(.indexTip)
            let middleTip = try observation.recognizedPoint(.middleTip)
            let thumbTip = try observation.recognizedPoint(.thumbTip)
            
            // Garantir que a confiança da detecção é alta o suficiente
            guard wristPoint.confidence > 0.3,
                  indexTip.confidence > 0.3,
                  middleTip.confidence > 0.3,
                  thumbTip.confidence > 0.3 else { return }
            
            let wristLocation = wristPoint.location
            let indexLocation = indexTip.location
            let middleLocation = middleTip.location
            
            // Calcular distâncias dos dedos em relação ao pulso
            let indexDistance = hypot(indexLocation.x - wristLocation.x, indexLocation.y - wristLocation.y)
            let middleDistance = hypot(middleLocation.x - wristLocation.x, middleLocation.y - wristLocation.y)
            
            let avgDistance = (indexDistance + middleDistance) / 2
            
            // Lógica de Pinça (Pinch) para modo Sandbox de CoreML
            let pinchDistance = hypot(indexLocation.x - thumbTip.location.x, indexLocation.y - thumbTip.location.y)
            let isPinching = pinchDistance < 0.04
            let normalizedIndexLocation = CGPoint(x: indexLocation.x, y: 1.0 - indexLocation.y)
            
            // Heurística simples
            let gesture: HandGesture
            if avgDistance > 0.25 {
                gesture = .openHand // Dedos longe do pulso
            } else if avgDistance < 0.12 {
                gesture = .fist // Dedos próximos ao pulso
            } else {
                gesture = .unknown
            }
            
            // A coordenada do pulso para o cursor principal
            let normalizedLocation = CGPoint(x: wristLocation.x, y: 1.0 - wristLocation.y)
            
            DispatchQueue.main.async { [weak self] in
                self?.onHandDetected?(gesture, normalizedLocation, detectedPoints)
                
                // Emite estado de pinça para o Sandbox
                self?.onPinchStateChanged?(isPinching, normalizedIndexLocation)
                if isPinching {
                    self?.onObservationBuffered?(observation)
                }
            }
        } catch {
            // Pontos não reconhecidos
        }
    }
}
