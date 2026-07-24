// Ref: docs/sdd/FallingOrbs_GameLoop_Spec.md
import SwiftUI

struct ProbabilityItem: Identifiable {
    var id: String { key }
    let key: String
    let value: Double
}

struct ProbabilityRowView: View {
    let item: ProbabilityItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(symbolForLabel(item.key)) \(item.key)")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { barGeo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(colorForLabel(item.key))
                        .frame(width: max(0, barGeo.size.width * CGFloat(item.value)))
                }
            }
            .frame(height: 6)
            
            Text("\(Int(item.value * 100))%")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(isSelected ? .green : .white.opacity(0.8))
                .frame(width: 34, alignment: .trailing)
        }
    }
    
    private func symbolForLabel(_ label: String) -> String {
        switch label {
        case "Circle": return "◯"
        case "Square": return "☐"
        case "Triangle": return "△"
        case "V": return "∨"
        case "Z": return "Z"
        case "Infinite": return "∞"
        default: return "❓"
        }
    }
    
    private func colorForLabel(_ label: String) -> Color {
        switch label {
        case "Circle": return .blue
        case "Square": return .orange
        case "Triangle": return .green
        case "V": return .pink
        case "Z": return .purple
        case "Infinite": return .cyan
        default: return .gray
        }
    }
}

struct FallingOrbsGameView: View {
    @Binding var isPresented: Bool
    @State private var viewModel: FallingOrbsGameViewModel
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        let visionService = VisionService()
        self._viewModel = State(initialValue: FallingOrbsGameViewModel(visionService: visionService))
    }
    
    private var topProbabilities: [ProbabilityItem] {
        viewModel.allProbabilities
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { ProbabilityItem(key: $0.key, value: $0.value) }
    }
    
    var body: some View {
        ZStack {
            // Layer 1: Feed da Câmera no fundo (Espelhado horizontalmente)
            CameraPreview(session: viewModel.visionService.captureSession)
                .scaleEffect(x: -1, y: 1)
                .ignoresSafeArea()
            
            // Layer 2: Orbs caindo, rastro do desenho e esqueleto com correção AspectFill
            GeometryReader { geometry in
                ZStack {
                    // Orbs caindo
                    ForEach(viewModel.orbs) { orb in
                        OrbView(orb: orb, containerSize: geometry.size)
                    }
                    
                    // Rastro contínuo do desenho feito no ar (com alinhamento perfeito na câmera)
                    if viewModel.drawingPathPoints.count > 1 {
                        pathView(in: geometry.size)
                    }
                    
                    // Esqueleto visual da mão (alinhado perfeitamente com os dedos físicos)
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
            
            // Layer 3: HUD (Vidas, Score e IA Debug)
            VStack {
                HStack(alignment: .top) {
                    livesHudView
                    
                    Spacer()
                    
                    debugHudView
                }
                .padding()
                
                Spacer()
                
                // Botão de Sair no rodapé
                HStack {
                    Button(action: {
                        viewModel.stopGame()
                        isPresented = false
                    }) {
                        Label("Voltar ao Menu", systemImage: "arrow.left")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding()
            }
            
            // Layer 4: Overlay de Game Over
            if viewModel.gameState == .gameOver {
                gameOverOverlayView
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.stopGame()
        }
    }
    
    // MARK: - Alinhamento Perfeito de Coordenadas (AspectFill Crop Correction)
    
    private func convertNormalizedPoint(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let camAspect: CGFloat = 16.0 / 9.0 // Aspect ratio padrão de webcams HD/4K no Mac
        let viewAspect = size.width / size.height
        
        let x = point.x
        let y = point.y
        
        if viewAspect < camAspect {
            // A janela é mais estreita que 16:9 -> Laterais da imagem são cortadas
            let scaledWidth = size.height * camAspect
            let offsetX = (scaledWidth - size.width) / 2.0
            let realX = (x * scaledWidth) - offsetX
            let realY = y * size.height
            return CGPoint(x: realX, y: realY)
        } else {
            // A janela é mais larga que 16:9 -> Topo/base da imagem são cortados
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
    
    private var livesHudView: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(index < viewModel.lives ? .red : .gray.opacity(0.5))
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private var debugHudView: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("Pontuação: \(viewModel.score)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(viewModel.isPinchingActive ? "👌 Desenhando" : "🖐️ Mão Pronta")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(viewModel.isPinchingActive ? .green : .gray)
                    
                    Spacer()
                    
                    Text("IA Debug")
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
                            isSelected: item.key == viewModel.lastRecognizedGesture
                        )
                    }
                }
            }
            .padding(10)
            .frame(width: 220)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 5)
        }
        .padding(12)
    }
    
    private var gameOverOverlayView: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("GAME OVER")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                
                VStack(spacing: 8) {
                    Text("Pontuação Final")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.startGame()
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
                        isPresented = false
                    }) {
                        Text("Menu Principal")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.5))
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
}
