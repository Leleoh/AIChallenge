// Ref: docs/sdd/FallingOrbs_GameLoop_Spec.md
import Foundation

/// Representa o tipo de gesto exigido por um Orb
enum GestureType: String, CaseIterable, Identifiable {
    case circle = "Circle"
    case square = "Square"
    case triangle = "Triangle"
    case lineV = "V"
    case lineZ = "Z"
    case infinite = "Infinite"
    
    var id: String { self.rawValue }
    
    /// Ícone ou símbolo amigável para exibir na UI
    var symbol: String {
        switch self {
        case .circle: return "◯"
        case .square: return "☐"
        case .triangle: return "△"
        case .lineV: return "∨"
        case .lineZ: return "Z"
        case .infinite: return "∞"
        }
    }
}

/// Representa um Orb/Inimigo caindo na tela
struct FallingOrb: Identifiable, Equatable {
    let id: UUID = UUID()
    var positionY: Double // Posição normalizada (0.0 no topo, 1.0 no fundo)
    let positionX: Double // Posição X normalizada (0.1 a 0.9)
    let targetGesture: GestureType
    var isPopped: Bool = false
}

/// Estado do Game Loop
enum GameState {
    case ready
    case playing
    case paused
    case gameOver
}
