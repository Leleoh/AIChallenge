// Ref: docs/sdd/CowreML_MainMenu_Spec.md
import SwiftUI

struct GesturesGuideModalView: View {
    @Binding var isPresented: Bool
    
    private struct GestureGuideItem {
        let name: String
        let systemImageName: String?
        let textSymbol: String?
        let color: Color
        let desc: String
    }
    
    private let gestures: [GestureGuideItem] = [
        GestureGuideItem(name: "Quadrado", systemImageName: "square", textSymbol: nil, color: .cyan, desc: "Desenhe 4 lados retos"),
        GestureGuideItem(name: "Círculo", systemImageName: "circle", textSymbol: nil, color: .purple, desc: "Desenhe uma volta redonda"),
        GestureGuideItem(name: "Triângulo", systemImageName: "triangle", textSymbol: nil, color: .orange, desc: "Desenhe um triângulo com 3 pontas"),
        GestureGuideItem(name: "Letra V", systemImageName: nil, textSymbol: "V", color: .green, desc: "Faça um movimento rápido em V"),
        GestureGuideItem(name: "Letra Z", systemImageName: nil, textSymbol: "Z", color: .yellow, desc: "Desenhe um Z no ar"),
        GestureGuideItem(name: "Infinito", systemImageName: "infinity", textSymbol: nil, color: .pink, desc: "Desenhe um laço em 8 deitado")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Cabeçalho
                VStack(spacing: 8) {
                    Text("🛸 COMO JOGAR 🛸")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                    
                    Text("Junte o Polegar e o Indicador 👌 e desenhe o gesto no ar para desligar o feixe do OVNI!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Text("Faça os desenhos com calma, você pode usar tanto a mão esquerda quanto a direita.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                // Grid de Gestos Suportados
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                    ForEach(gestures, id: \.name) { item in
                        HStack(spacing: 14) {
                            Group {
                                if let systemName = item.systemImageName {
                                    Image(systemName: systemName)
                                        .font(.system(size: 24, weight: .black))
                                } else if let text = item.textSymbol {
                                    Text(text)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                }
                            }
                            .foregroundColor(item.color)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(item.desc)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(item.color.opacity(0.5), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal)
                
                // Botão Fechar
                Button(action: {
                    isPresented = false
                }) {
                    Text("Entendi, Vamos Jogar!")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .green.opacity(0.5), radius: 8)
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .cornerRadius(28)
            .shadow(radius: 20)
            .frame(maxWidth: 720)
        }
    }
}
