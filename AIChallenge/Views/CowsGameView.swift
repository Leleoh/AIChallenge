// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import SwiftUI
import SpriteKit
import Vision

struct CowsGameView: View {
    @Binding var isPresented: Bool
    
    @State private var viewModel: CowsGameViewModel
    @State private var scene: CowsGameScene = {
        let newScene = CowsGameScene(size: CowsGameScene.nativeSize)
        newScene.scaleMode = .resizeFill
        return newScene
    }()
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        let visionService = VisionService()
        self._viewModel = State(initialValue: CowsGameViewModel(visionService: visionService))
    }
    
    private var topProbabilities: [ProbabilityItem] {
        viewModel.allProbabilities
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { ProbabilityItem(key: $0.key, value: $0.value) }
    }
    
    var body: some View {
        ZStack {
            // Layer 1: Feed da Câmera no fundo (Espelhado horizontalmente igual ao FallingOrbs)
            CameraPreview(session: viewModel.visionService.captureSession)
                .scaleEffect(x: -1, y: 1)
                .ignoresSafeArea()
                .opacity(0.001) // Oculto sob a arte do jogo para preservar a estética 8-Bit
            
            // Layer 2: SpriteKit Game Scene (Cenário Pixel Art + Naves + Vacas)
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            // Layer 3: Overlay do Traçado da Mão & Esqueleto (Alinhado perfeitamente com a Câmera)
            GeometryReader { geometry in
                ZStack {
                    if viewModel.drawingPathPoints.count > 1 {
                        pathView(in: geometry.size)
                    }
                    
                    // Esqueleto visual dos pontos da mão
                    ForEach(0..<viewModel.currentHandPoints.count, id: \.self) { index in
                        let convertedPoint = convertNormalizedPoint(viewModel.currentHandPoints[index], in: geometry.size)
                        Circle()
                            .fill(Color.cyan.opacity(0.8))
                            .frame(width: 10, height: 10)
                            .position(convertedPoint)
                    }
                }
            }
            .ignoresSafeArea()
            
            // Layer 4: HUD & Controles da UI Superior
            VStack {
                HStack(alignment: .top) {
                    // Botão Voltar + Contador de Vidas
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            stopGame()
                            isPresented = false
                        }) {
                            Label("Voltar ao Menu", systemImage: "arrow.left")
                                .font(.headline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        
                        livesHudView
                    }
                    
                    Spacer()
                    
                    // Banner de Feedback Temporário (Toast)
                    if let feedback = viewModel.feedbackMessage {
                        Text(feedback)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(12)
                            .shadow(radius: 6)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: viewModel.feedbackMessage)
                    }
                    
                    Spacer()
                    
                    // Placar + Debug de IA
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Pontos: \(viewModel.score)")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4)
                        
                        debugHudView
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Layer 5: Modal de Game Over
            if viewModel.gameState == .gameOver {
                gameOverOverlayView
            }
        }
        .onAppear {
            setupGameBridge()
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    // MARK: - Conexão ViewModel & SpriteKit Scene
    private func setupGameBridge() {
        scene.viewModel = viewModel
        
        viewModel.onRescueTriggered = { targetId in
            scene.performRescue(targetId: targetId)
        }
        
        viewModel.onStartGameTriggered = {
            scene.startSpawningUFOs()
        }
    }
    
    private func startGame() {
        viewModel.startGame()
    }
    
    private func stopGame() {
        scene.stopSpawningUFOs()
        viewModel.stopGame()
    }
    
    // MARK: - Subviews de HUD & Debug
    
    private var livesHudView: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.maxLives, id: \.self) { index in
                Text("🐮")
                    .font(.system(size: 26))
                    .opacity(index < viewModel.lives ? 1.0 : 0.25)
                    .scaleEffect(index < viewModel.lives ? 1.0 : 0.8)
                    .animation(.spring(), value: viewModel.lives)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.65))
        .cornerRadius(12)
    }
    
    private var debugHudView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(viewModel.isPinchingActive ? "👌 Desenhando" : "🖐️ Mão Pronta")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(viewModel.isPinchingActive ? .green : .gray)
                
                Spacer()
                
                Text("IA CoreML")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.purple)
            }
            
            Divider().background(Color.white.opacity(0.3))
            
            if topProbabilities.isEmpty {
                Text("Aguardando gesto...")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                ForEach(topProbabilities) { item in
                    ProbabilityRowView(
                        item: item,
                        isSelected: item.key == viewModel.lastDetectedGesture?.label
                    )
                }
            }
        }
        .padding(10)
        .frame(width: 210)
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private var gameOverOverlayView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🛸 GAME OVER 🛸")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                
                VStack(spacing: 8) {
                    Text("Vacas Resgatadas (Pontuação)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.restartGame()
                    }) {
                        Text("Jogar Novamente")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        stopGame()
                        isPresented = false
                    }) {
                        Text("Menu Principal")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(radius: 20)
        }
    }
    
    // MARK: - Conversão e Alinhamento Perfeito de Coordenadas (AspectFill Crop Correction)
    private func convertNormalizedPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let camAspect: CGFloat = 16.0 / 9.0
        let viewAspect = size.width / size.height
        
        let x = point.x
        let y = point.y
        
        if viewAspect < camAspect {
            let scaledWidth = size.height * camAspect
            let offsetX = (scaledWidth - size.width) / 2.0
            let realX = (x * scaledWidth) - offsetX
            let realY = y * size.height
            return CGPoint(x: realX, y: realY)
        } else {
            let scaledHeight = size.width / camAspect
            let offsetY = (scaledHeight - size.height) / 2.0
            let realX = x * size.width
            let realY = (y * scaledHeight) - offsetY
            return CGPoint(x: realX, y: realY)
        }
    }
    
    private func pathView(in size: CGSize) -> some View {
        Path { path in
            let firstConverted = convertNormalizedPoint(viewModel.drawingPathPoints[0], in: size)
            path.move(to: firstConverted)
            
            for point in viewModel.drawingPathPoints.dropFirst() {
                let converted = convertNormalizedPoint(point, in: size)
                path.addLine(to: converted)
            }
        }
        .stroke(
            LinearGradient(
                colors: [.cyan, .purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: .cyan.opacity(0.8), radius: 8)
    }
}
