// Ref: docs/sdd/CowreML_MainMenu_Spec.md
import SwiftUI

struct GesturesGuideModalView: View {
    @Binding var isPresented: Bool
    
    private let gestures: [(name: String, symbol: String, color: Color, desc: String)] = [
        ("Quadrado", "⏹", .cyan, "Desenhe 4 lados retos"),
        ("Círculo", "⏺", .purple, "Desenhe uma volta redonda"),
        ("Triângulo", "▲", .orange, "Desenhe um triângulo com 3 pontas"),
        ("Letra V", "V", .green, "Faça um movimento rápido em V"),
        ("Letra Z", "Z", .yellow, "Desenhe um Z no ar"),
        ("Infinito", "∞", .pink, "Desenhe um laço em 8 deitado")
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
                            Text(item.symbol)
                                .font(.system(size: 36, weight: .bold))
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
                                .stroke(item.color.opacity(0.4), lineWidth: 1.5)
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
