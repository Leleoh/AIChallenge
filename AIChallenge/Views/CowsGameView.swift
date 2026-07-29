// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import SwiftUI
import SpriteKit
import Vision
import AVFoundation

// MARK: - Subview Isolada do SpriteKit (Impede re-avaliações da renderização pelo SwiftUI)
private struct IsolatedSpriteView: View, Equatable {
    let scene: CowsGameScene
    
    static func == (lhs: IsolatedSpriteView, rhs: IsolatedSpriteView) -> Bool {
        return true
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

// MARK: - Subview Isolada da Câmera
private struct IsolatedCameraView: View, Equatable {
    let session: AVCaptureSession
    
    static func == (lhs: IsolatedCameraView, rhs: IsolatedCameraView) -> Bool {
        return true
    }
    
    var body: some View {
        CameraPreview(session: session)
            .scaleEffect(x: -1, y: 1)
            .ignoresSafeArea()
            .opacity(0.001)
    }
}

struct CowsGameView: View {
    @Binding var isPresented: Bool
    
    @AppStorage("cowsHighScore") private var highScore: Int = 0
    @StateObject private var soundService = SoundService.shared
    @State private var viewModel: CowsGameViewModel
    @State private var isGuidePresented: Bool = false
    
    @State private var scene: CowsGameScene = {
        let newScene = CowsGameScene(size: CowsGameScene.nativeSize)
        newScene.scaleMode = .resizeFill
        return newScene
    }()
    
    init(isPresented: Binding<Bool> = .constant(true)) {
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
            // Layer 1: Feed da Câmera no fundo (Isolado)
            IsolatedCameraView(session: viewModel.visionService.captureSession)
            
            // Layer 2: SpriteKit Game Scene Única & Contínua (Isolada de Re-avaliação)
            IsolatedSpriteView(scene: scene)
            
            // Layer 3: Overlay da Interface de MENU (Quando em estado .ready)
            if viewModel.gameState == .ready {
                menuOverlayView
                    .transition(.opacity)
            }
            
            // Layer 4: Overlay do Traçado da Mão & Esqueleto (Durante o jogo)
            if viewModel.gameState == .playing || viewModel.gameState == .paused {
                GeometryReader { geometry in
                    ZStack {
                        if viewModel.drawingPathPoints.count > 1 {
                            pathView(in: geometry.size)
                        }
                        
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
                
                // Layer 5: HUD Superior durante Gameplay
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 10) {
                            Button(action: {
                                viewModel.pauseGame()
                            }) {
                                Label("Pausar", systemImage: "pause.fill")
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
            }
            
            // Layer 6: Overlay de Contagem Regressiva (3, 2, 1)
            if let count = viewModel.countdownNumber {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        Text("\(count)")
                            .font(.system(size: 140, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 12)
                            .scaleEffect(1.1)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(), value: count)
                        
                        Text("PREPARE-SE PARA O RESGATE!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
            }
            
            // Layer 7: Modal de Pausa
            if viewModel.gameState == .paused {
                pauseOverlayView
            }
            
            // Layer 8: Modal de Game Over
            if viewModel.gameState == .gameOver {
                gameOverOverlayView
            }
            
            // Layer 9: Modal Guia de Gestos
            if isGuidePresented {
                GesturesGuideModalView(isPresented: $isGuidePresented)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.spring(), value: isGuidePresented)
            }
        }
        .onAppear {
            setupGameBridge()
            SoundService.shared.playBGM(named: "OST", volume: 0.18)
        }
        .onReceive(NotificationCenter.default.publisher(for: .startMoovniGame)) { _ in
            startSeamlessGame()
        }
        .onReceive(NotificationCenter.default.publisher(for: .startPromptWaiterGame)) { _ in
            startSeamlessGame()
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
    
    private func startSeamlessGame() {
        scene.hideMenuState()
        viewModel.startGame()
    }
    
    private func returnToSeamlessMenu() {
        scene.stopSpawningUFOs()
        scene.showMenuState()
        viewModel.returnToMenu()
    }
    
    // MARK: - Subviews de UI
    
    private var soundControlButtonsView: some View {
        HStack(spacing: 10) {
            Button(action: {
                soundService.isMusicEnabled.toggle()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: soundService.isMusicEnabled ? "music.note" : "speaker.slash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(soundService.isMusicEnabled ? "Música ON" : "Música OFF")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(soundService.isMusicEnabled ? Color.purple.opacity(0.8) : Color.black.opacity(0.75))
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            Button(action: {
                soundService.isSFXEnabled.toggle()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: soundService.isSFXEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(soundService.isSFXEnabled ? "Som ON" : "Som OFF")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(soundService.isSFXEnabled ? Color.blue.opacity(0.8) : Color.black.opacity(0.75))
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var menuOverlayView: some View {
        VStack {
            HStack {
                soundControlButtonsView
                
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                }
            }
            .padding()
            
            Spacer()
            
            // Título Principal M.O.O.V.N.I.
            Text("M.O.O.V.N.I.")
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .shadow(color: .orange, radius: 16)
                .shadow(color: .black, radius: 10)
            
            Spacer()
            
            // Controles Principais
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        startSeamlessGame()
                    }
                }) {
                    Text("INICIAR RESGATE")
                        .font(.title2)
                        .bold()
                        .frame(width: 280, height: 56)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.5), radius: 10)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isGuidePresented = true
                }) {
                    Text("COMO JOGAR (GESTOS)")
                        .font(.headline)
                        .bold()
                        .frame(width: 280, height: 48)
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
    }
    
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
    
    private var pauseOverlayView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("JOGO PAUSADO ⏸")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                
                soundControlButtonsView
                
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.resumeGame()
                    }) {
                        Text("Continuar Resgate")
                            .font(.title3)
                            .bold()
                            .frame(width: 240, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            returnToSeamlessMenu()
                        }
                    }) {
                        Text("Voltar ao Menu")
                            .font(.title3)
                            .bold()
                            .frame(width: 240, height: 50)
                            .background(Color.gray.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(14)
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
    
    private var gameOverOverlayView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🛸 GAME OVER 🛸")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                
                VStack(spacing: 8) {
                    Text("Animais Resgatados (Pontuação)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        startSeamlessGame()
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
                        withAnimation(.easeInOut(duration: 0.4)) {
                            returnToSeamlessMenu()
                        }
                    }) {
                        Text("Voltar ao Menu")
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
    
    // MARK: - Conversão e Alinhamento Perfeito de Coordenadas
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
