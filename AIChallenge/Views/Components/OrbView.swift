// Ref: docs/sdd/FallingOrbs_GameLoop_Spec.md
import SwiftUI

struct OrbView: View {
    let orb: FallingOrb
    let containerSize: CGSize
    
    private var orbSize: CGFloat { 70 }
    
    var body: some View {
        let xPos = orb.positionX * containerSize.width
        let yPos = orb.positionY * (containerSize.height - orbSize) + (orbSize / 2)
        
        ZStack {
            // Esfera com gradiente e iluminação
            Circle()
                .fill(
                    LinearGradient(
                        colors: [colorForGesture(orb.targetGesture), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: colorForGesture(orb.targetGesture).opacity(0.6), radius: 10, x: 0, y: 4)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            
            // Símbolo e texto do gesto
            VStack(spacing: 2) {
                Text(orb.targetGesture.symbol)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(orb.targetGesture.rawValue)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(width: orbSize, height: orbSize)
        .position(x: xPos, y: yPos)
    }
    
    private func colorForGesture(_ gesture: GestureType) -> Color {
        switch gesture {
        case .circle: return .blue
        case .square: return .orange
        case .triangle: return .green
        case .lineV: return .pink
        case .lineZ: return .purple
        case .infinite: return .cyan
        }
    }
}
