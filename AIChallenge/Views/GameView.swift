import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewModel()
    @Binding var isPlaying: Bool
    
    var body: some View {
        ZStack {
            // Camada de vídeo e tracking forçada para a proporção da câmera (16:9)
            // Isso previne achatamento da imagem mantendo os pontos matematicamente perfeitos
            ZStack {
                CameraPreview(session: viewModel.visionService.captureSession)
                
                // Balões e Cursor
                GeometryReader { geometry in
                // Renderizando cada balão
                ForEach(viewModel.session.activeBalloons) { balloon in
                    ZStack {
                        Text(balloon.symbol)
                            .font(.system(size: 80))
                        
                        // Ícone do gesto exigido
                        Text(balloon.requiredGesture == .openHand ? "🖐" : "✊")
                            .font(.system(size: 30))
                            .background(Circle().fill(Color.white).opacity(0.8).frame(width: 40, height: 40))
                            .offset(x: 30, y: -30)
                    }
                    .position(
                        x: balloon.position.x * geometry.size.width,
                        y: balloon.position.y * geometry.size.height
                    )
                    .animation(.spring(), value: balloon.position)
                }
                
                // Pontos individuais dos dedos (Skeleton)
                ForEach(0..<viewModel.handPoints.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 14, height: 14)
                        .position(
                            x: viewModel.handPoints[index].x * geometry.size.width,
                            y: viewModel.handPoints[index].y * geometry.size.height
                        )
                }
                
                // Cursor visual (A posição da mão principal - pulso)
                Circle()
                    .fill(cursorColor(for: viewModel.currentGesture))
                    .frame(width: 25, height: 25)
                    .position(
                        x: viewModel.cursorPosition.x * geometry.size.width,
                        y: viewModel.cursorPosition.y * geometry.size.height
                    )
                    .animation(.linear(duration: 0.1), value: viewModel.cursorPosition)
                }
            }
            .aspectRatio(16.0 / 9.0, contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea()
            
            // UI Superior (Placar e Botão de Sair)
            VStack {
                HStack {
                    Button(action: {
                        viewModel.endGame()
                        isPlaying = false
                    }) {
                        Text("Encerrar Sessão")
                            .font(.headline)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Placar: \(viewModel.session.score)")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.endGame()
        }
    }
    
    private func cursorColor(for gesture: HandGesture) -> Color {
        switch gesture {
        case .openHand: return Color.green
        case .fist: return Color.red
        case .unknown: return Color.blue
        }
    }
}
