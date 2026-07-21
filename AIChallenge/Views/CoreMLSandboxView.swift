import SwiftUI

struct CoreMLSandboxView: View {
    @Binding var isPresented: Bool
    @State private var viewModel = SandboxViewModel(visionService: VisionService())
    
    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.visionService.captureSession)
                .edgesIgnoringSafeArea(.all)
            
            // Desenho do traçado (Path)
            GeometryReader { geometry in
                Path { path in
                    guard let firstPoint = viewModel.drawnPoints.first else { return }
                    
                    let startPoint = CGPoint(
                        x: firstPoint.x * geometry.size.width,
                        y: firstPoint.y * geometry.size.height
                    )
                    path.move(to: startPoint)
                    
                    for point in viewModel.drawnPoints.dropFirst() {
                        let nextPoint = CGPoint(
                            x: point.x * geometry.size.width,
                            y: point.y * geometry.size.height
                        )
                        path.addLine(to: nextPoint)
                    }
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 0)
            }
            
            // UI Overlay
            VStack {
                Text("Modo Sandbox (CoreML)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.top, 40)
                
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
                    VStack {
                        Text("Forma: \(prediction.label)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(prediction.confidence > 0.7 ? .green : .orange)
                        
                        Text("Confiança: \(String(format: "%.0f%%", prediction.confidence * 100))")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(Color.black.opacity(0.7))
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
