// Ref: docs/sdd/SpriteKit_CowsGame_Spec.md
import SwiftUI
import SpriteKit

struct CowsGameView: View {
    @Binding var isPresented: Bool
    
    @State private var scene: CowsGameScene = {
        let newScene = CowsGameScene(size: CowsGameScene.nativeSize)
        // ESSENCIAL: Garante que o buffer do Metal nunca seja esticado pelo Mac
        newScene.scaleMode = .resizeFill 
        return newScene
    }()
    
    var body: some View {
        ZStack {
            // Layer 1: SpriteView Nativa com .resizeFill
            SpriteView(scene: scene)
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
