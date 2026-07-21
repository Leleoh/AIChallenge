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
    
    func predict(observations: [VNHumanHandPoseObservation]) -> GesturePrediction? {
        guard let model = model, observations.count > 0 else { return nil }
        
        do {
            // Criar o MLMultiArray de input no formato [1, windowSize, 3, 21]
            let poses = try MLMultiArray(shape: [1, NSNumber(value: windowSize), 3, 21], dataType: .float32)
            
            let count = min(observations.count, windowSize)
            for i in 0..<count {
                let obs = observations[i]
                let frameMultiArray = try obs.keypointsMultiArray()
                
                // O frameMultiArray gerado pelo Vision tem formato [3, 21]
                for c in 0..<3 {
                    for v in 0..<21 {
                        let idx = [0, NSNumber(value: i), NSNumber(value: c), NSNumber(value: v)]
                        let val = frameMultiArray[[NSNumber(value: c), NSNumber(value: v)]]
                        poses[idx] = val
                    }
                }
            }
            
            // Se o usuário soltou a pinça muito rápido (menos de 60 frames), 
            // repetimos o último frame para preencher o resto do array de 2 segundos.
            if count < windowSize && count > 0 {
                let lastObs = observations[count - 1]
                let frameMultiArray = try lastObs.keypointsMultiArray()
                for i in count..<windowSize {
                    for c in 0..<3 {
                        for v in 0..<21 {
                            let idx = [0, NSNumber(value: i), NSNumber(value: c), NSNumber(value: v)]
                            let val = frameMultiArray[[NSNumber(value: c), NSNumber(value: v)]]
                            poses[idx] = val
                        }
                    }
                }
            }
            
            let input = MagicHandsMLInput(poses: poses)
            let output = try model.prediction(input: input)
            
            let label = output.label
            let prob = output.labelProbabilities[label] ?? 0.0
            
            return GesturePrediction(label: label, confidence: prob)
            
        } catch {
            print("Erro na predição do CoreML: \(error)")
            return nil
        }
    }
}
