import Foundation

enum DrawingState {
    case idle
    case drawing // O usuário está com a 'pinça' fechada
    case analyzing // O modelo CoreML está processando os frames
}
