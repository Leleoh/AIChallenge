// Ref: docs/sdd/CoreML_Gestures_Spec.md
import Foundation
import CoreML
import Vision

class CoreMLService {
    static let shared = CoreMLService()
    
    private var model: MagicHandsML?
    let windowSize = 60
    
    init() {
        do {
            let config = MLModelConfiguration()
            self.model = try MagicHandsML(configuration: config)
        } catch {
            print("Erro ao carregar MagicHandsML: \(error)")
        }
    }
    
    func predict(observations: [VNHumanHandPoseObservation]) throws -> GesturePrediction? {
        if model == nil {
            throw NSError(domain: "CoreML", code: -1, userInfo: [NSLocalizedDescriptionKey: "Modelo MagicHandsML não carregou. Verifique se o Target está marcado no Xcode."])
        }
        guard let model = model, observations.count > 0 else { return nil }
        
        let poses = try MLMultiArray(shape: [NSNumber(value: windowSize), 3, 21], dataType: .float32)
        
        let jointsOrder: [VNHumanHandPoseObservation.JointName] = [
            .wrist,
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]
        
        let ptr = poses.dataPointer.bindMemory(to: Float32.self, capacity: windowSize * 3 * 21)
        let strides = poses.strides.map { $0.intValue }
        
        let count = min(observations.count, windowSize)
        var hasLogged = false
        
        for i in 0..<count {
            let obs = observations[i]
            
            for v in 0..<21 {
                let jointName = jointsOrder[v]
                let point = try? obs.recognizedPoint(jointName)
                
                let rawX = Float32(point?.location.x ?? 0.0)
                let confidence = Float32(point?.confidence ?? 0.0)
                
                // O usuário confirmou que a orientação é a mesma do QuickTime (pinta no mesmo lado), 
                // então não precisamos inverter o X.
                let x = confidence > 0.0 ? rawX : 0.0
                let y = Float32(point?.location.y ?? 0.0) // Vision usa bottom-left nativamente, exatamente o que o CoreML espera
                
                
                // C=0 -> X
                ptr[i * strides[0] + 0 * strides[1] + v * strides[2]] = x
                // C=1 -> Y
                ptr[i * strides[0] + 1 * strides[1] + v * strides[2]] = y
                // C=2 -> Confidence
                ptr[i * strides[0] + 2 * strides[1] + v * strides[2]] = confidence
            }
        }
        
        // Se precisarmos preencher o resto com o último frame
        if count < windowSize && count > 0 {
            let lastObs = observations[count - 1]
            for i in count..<windowSize {
                for v in 0..<21 {
                    let jointName = jointsOrder[v]
                    let point = try? lastObs.recognizedPoint(jointName)
                    
                    let rawX = Float32(point?.location.x ?? 0.0)
                    let confidence = Float32(point?.confidence ?? 0.0)
                    
                    let x = confidence > 0.0 ? rawX : 0.0
                    let y = Float32(point?.location.y ?? 0.0)
                    
                    ptr[i * strides[0] + 0 * strides[1] + v * strides[2]] = x
                    ptr[i * strides[0] + 1 * strides[1] + v * strides[2]] = y
                    ptr[i * strides[0] + 2 * strides[1] + v * strides[2]] = confidence
                }
            }
        }
        
        let input = MagicHandsMLInput(poses: poses)
        let output = try model.prediction(input: input)
        
        let label = output.label
        let prob = output.labelProbabilities[label] ?? 0.0
        
        return GesturePrediction(label: label, confidence: prob, allProbabilities: output.labelProbabilities)
    }
}
