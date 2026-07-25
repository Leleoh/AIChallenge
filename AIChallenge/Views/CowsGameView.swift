// Ref: docs/sdd/SpriteKit_CowsGame_Spec.md
import SwiftUI
import SpriteKit

struct CowsGameView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit Game Scene (Ceu, Nuvens, Relevo e Pasto fiéis ao Figma)
                SpriteView(scene: makeScene(size: geometry.size))
                    .ignoresSafeArea()
                
                // Layer 2: HUD & Controles da UI
                VStack {
                    HStack {
                        Button(action: {
                            isPresented = false
                        }) {
                            Label("Voltar ao Menu", systemImage: "arrow.left")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("🐮 Modo Abdução 8-Bit")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
    
    private func makeScene(size: CGSize) -> CowsGameScene {
        let validSize = CGSize(
            width: max(300, size.width),
            height: max(300, size.height)
        )
        let scene = CowsGameScene(size: validSize)
        scene.scaleMode = .resizeFill
        return scene
    }
}
