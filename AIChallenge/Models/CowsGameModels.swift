// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import Foundation
import SwiftUI

extension GestureType {
    /// Nome amigável em português para exibição
    var displayName: String {
        switch self {
        case .square: return "Quadrado"
        case .circle: return "Círculo"
        case .triangle: return "Triângulo"
        case .lineV: return "Letra V"
        case .lineZ: return "Letra Z"
        case .infinite: return "Infinito"
        }
    }
    
    /// Ícone SFSymbol correspondente para renderização no HUD / badge
    var iconName: String {
        switch self {
        case .square: return "square"
        case .circle: return "circle"
        case .triangle: return "triangle"
        case .lineV: return "v.circle.fill"
        case .lineZ: return "z.circle.fill"
        case .infinite: return "infinity"
        }
    }
    
    /// Cor distinta associada ao gesto para facilidade visual
    var accentColor: Color {
        switch self {
        case .square: return .blue
        case .circle: return .green
        case .triangle: return .orange
        case .lineV: return .purple
        case .lineZ: return .yellow
        case .infinite: return .pink
        }
    }
}

/// Representa a estrutura de dados de uma abdução ativa na cena
struct AbductionTarget: Identifiable {
    let id: UUID
    let gestureRequired: GestureType
    var timeRemaining: TimeInterval
    var totalDuration: TimeInterval
    let cowIndex: Int // Identificador da vaca sendo abduzida
    var isRescued: Bool = false
    var isAbducted: Bool = false
    
    var progress: Double {
        max(0.0, min(1.0, 1.0 - (timeRemaining / totalDuration)))
    }
}
