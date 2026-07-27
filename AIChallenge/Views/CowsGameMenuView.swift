// Ref: docs/sdd/CowreML_MainMenu_Spec.md
import SwiftUI
import SpriteKit

// MARK: - Subview Isolada do Fundo Animado do Menu
private struct IsolatedSpriteMenuView: View, Equatable {
    let scene: CowsMenuScene
    
    static func == (lhs: IsolatedSpriteMenuView, rhs: IsolatedSpriteMenuView) -> Bool {
        return true
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

struct CowsGameMenuView: View {
    @Binding var isPresented: Bool
    
    @AppStorage("cowsHighScore") private var highScore: Int = 0
    @State private var isGameActive: Bool = false
    @State private var isGuidePresented: Bool = false
    
    @State private var menuScene: CowsMenuScene = {
        let scene = CowsMenuScene(size: CowsMenuScene.nativeSize)
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    var body: some View {
        Group {
            if isGameActive {
                CowsGameView(isPresented: $isGameActive)
            } else {
                ZStack {
                    // Layer 1: Fundo Animado SpriteKit 8-Bit (Isolado)
                    IsolatedSpriteMenuView(scene: menuScene)
                    
                    // Layer 2: Overlay da Interface do Menu
                    VStack {
                        // Top Bar: Botão Voltar & Recorde
                        HStack {
                            Button(action: {
                                isPresented = false
                            }) {
                                Label("Voltar ao Menu Principal", systemImage: "arrow.left")
                                    .font(.headline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            if highScore > 0 {
                                HStack(spacing: 6) {
                                    Text("🏆 Recorde:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(highScore) pts")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.75))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Título Principal M.O.O.V.N.I.
                        VStack(spacing: 10) {
                            Text("M.O.O.V.N.I.")
                                .font(.system(size: 72, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 15)
                                .shadow(color: .black, radius: 8)
                            
                            Text("MOO-TION OPERATION & VISION INTERFACE")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                                .tracking(3)
                                .shadow(color: .black, radius: 6)
                        }
                        
                        Spacer()
                        
                        // Controles Principais (Jogar & Como Jogar)
                        VStack(spacing: 18) {
                            Button(action: {
                                isGameActive = true
                            }) {
                                HStack(spacing: 12) {
                                    Text("🛸")
                                        .font(.title)
                                    Text("INICIAR RESGATE")
                                        .font(.title2)
                                        .bold()
                                }
                                .frame(width: 320, height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .green.opacity(0.6), radius: 12)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                isGuidePresented = true
                            }) {
                                HStack(spacing: 10) {
                                    Text("❓")
                                        .font(.headline)
                                    Text("COMO JOGAR (GESTOS)")
                                        .font(.headline)
                                        .bold()
                                }
                                .frame(width: 320, height: 50)
                                .background(Color.black.opacity(0.75))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.cyan.opacity(0.6), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 60)
                    }
                    
                    // Layer 3: Modal de Como Jogar (Guia de Gestos)
                    if isGuidePresented {
                        GesturesGuideModalView(isPresented: $isGuidePresented)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.spring(), value: isGuidePresented)
                    }
                }
            }
        }
    }
}
