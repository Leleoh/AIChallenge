import SwiftUI

struct CoreMLSandboxView: View {
    @Binding var isPresented: Bool
    @State private var viewModel = SandboxViewModel(visionService: VisionService())
    
    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.visionService.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // Wireframe Debug
            GeometryReader { geometry in
                // Aqui desenhamos as "bolinhas" nos dedos para garantir que o Vision está detectando
                ForEach(0..<viewModel.currentHandPoints.count, id: \.self) { i in
                    let point = viewModel.currentHandPoints[i]
                    
                    // Removendo qualquer inversão. Apenas a coordenada X bruta que a IA enxerga!
                    let xPos = point.x * geometry.size.width
                    let yPos = point.y * geometry.size.height
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(x: xPos, y: yPos)
                }
            }
            
            // UI Overlay
            VStack {
                Text("Desafio de Movimento")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("Desenhe: \(viewModel.targetGesture)")
                    .font(.system(size: 50, weight: .black))
                    .foregroundColor(.yellow)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(15)
                
                // Texto de Debug: FPS e Janela
                Text("Buffer de IA: \(viewModel.currentHandPoints.isEmpty ? "Sem Mão" : "Rastreando...")")
                    .foregroundColor(viewModel.currentHandPoints.isEmpty ? .red : .green)
                    .padding(.top, 5)
                
                if let error = viewModel.errorMessage {
                    Text("Erro CoreML: \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Voltar para Home")
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 20)
                
                if let prediction = viewModel.prediction {
                    VStack(spacing: 15) {
                        if viewModel.hasWon {
                            Text("🎉 Você Acertou!")
                                .font(.title)
                                .foregroundColor(.green)
                                .bold()
                            
                            Button(action: {
                                viewModel.pickNewTarget()
                            }) {
                                Text("Próximo Gesto")
                                    .font(.title2)
                                    .bold()
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        } else {
                            VStack(spacing: 5) {
                                Text("Detectando: \(prediction.label) (\(String(format: "%.0f%%", prediction.confidence * 100)))")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                    .animation(.default, value: prediction.label)
                                
                                // DEBUG VISUAL:
                                Text("Buffer: \(viewModel.observationBuffer.count)/60 frames")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                // Mostra os top 3 palpites da IA
                                let top3 = prediction.allProbabilities.sorted { $0.value > $1.value }.prefix(3)
                                ForEach(top3, id: \.key) { guess in
                                    Text("\(guess.key): \(String(format: "%.1f%%", guess.value * 100))")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding(30)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
