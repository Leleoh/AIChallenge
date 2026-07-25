import SwiftUI

struct HomeView: View {
    @AppStorage("lastScore") private var lastScore: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isSandboxMode: Bool = false
    @State private var isFallingOrbsMode: Bool = false
    @State private var isCowsMode: Bool = false
    
    var body: some View {
        Group {
            if isPlaying {
                GameView(isPlaying: $isPlaying)
            } else if isSandboxMode {
                CoreMLSandboxView(isPresented: $isSandboxMode)
            } else if isFallingOrbsMode {
                FallingOrbsGameView(isPresented: $isFallingOrbsMode)
            } else if isCowsMode {
                CowsGameView(isPresented: $isCowsMode)
            } else {
                VStack(spacing: 20) {
                    Text("Magic Therapy")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Última Pontuação: \(lastScore)")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        isCowsMode = true
                    }) {
                        Text("🐮 Modo Abdução 8-Bit (SpriteKit)")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(width: 340)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        isFallingOrbsMode = true
                    }) {
                        Text("🔮 Modo Queda de Orbs (CoreML)")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(width: 340)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        isPlaying = true
                    }) {
                        Text("🎈 Modo Balões MVP")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(width: 320)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        isSandboxMode = true
                    }) {
                        Text("🧪 Testar Gestos (CoreML Sandbox)")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(width: 320)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }
                .frame(minWidth: 550, minHeight: 450)
            }
        }
    }
}
