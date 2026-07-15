import Foundation

struct Balloon: Identifiable, Equatable {
    let id: UUID = UUID()
    var position: CGPoint // Posição normalizada (0.0 a 1.0) para se adaptar a qualquer tamanho de tela
    var isPopped: Bool = false
    var symbol: String = "🎈"
    var requiredGesture: HandGesture
}
