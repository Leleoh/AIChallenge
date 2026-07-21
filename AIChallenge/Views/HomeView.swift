import SwiftUI

struct HomeView: View {
    @AppStorage("lastScore") private var lastScore: Int = 0
    @State private var isPlaying: Bool = false
    @State private var isSandboxMode: Bool = false
    
    var body: some View {
        Group {
            if isPlaying {
                GameView(isPlaying: $isPlaying)
            } else if isSandboxMode {
                CoreMLSandboxView(isPresented: $isSandboxMode)
            } else {
                VStack(spacing: 30) {
                    Text("Magic Therapy")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Última Pontuação: \(lastScore)")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        isPlaying = true
                    }) {
                        Text("Iniciar Sessão")
                            .font(.title2)
                            .bold()
                            .padding()
                            .frame(width: 250)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        isSandboxMode = true
                    }) {
                        Text("🧪 Testar Gestos (CoreML)")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(width: 250)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
                }
                .frame(minWidth: 500, minHeight: 400)
            }
        }
    }
}
