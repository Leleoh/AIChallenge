import Foundation
import Observation
import CoreGraphics

@Observable
class GameViewModel {
    var session: GameSession
    var currentGesture: HandGesture = .unknown
    var cursorPosition: CGPoint = CGPoint(x: 0.5, y: 0.5) // Posição normalizada inicial no centro
    
    // Serviço injetável
    private var visionService: VisionService
    
    // Timer para gerar os balões
    private var spawnTimer: Timer?
    
    init(visionService: VisionService = VisionService()) {
        self.session = GameSession()
        self.visionService = visionService
        
        setupVisionCallback()
    }
    
    private func setupVisionCallback() {
        visionService.onHandDetected = { [weak self] gesture, position in
            guard let self = self else { return }
            
            // A atualização de propriedades de interface através de @Observable
            // idealmente deve ocorrer na main thread. Como o callback já 
            // dispara no main thread (no VisionService), está seguro.
            self.currentGesture = gesture
            self.cursorPosition = position
            
            self.processGesture(gesture)
        }
    }
    
    func startGame() {
        session.isPlaying = true
        session.score = 0
        session.activeBalloons.removeAll()
        
        visionService.start()
        
        // Gera um balão a cada 2 segundos
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.spawnBalloon()
        }
    }
    
    func spawnBalloon() {
        // Posição aleatória na tela (normalizada entre 0.1 e 0.9 para não colar nas bordas)
        let randomX = CGFloat.random(in: 0.1...0.9)
        let randomY = CGFloat.random(in: 0.1...0.9)
        let position = CGPoint(x: randomX, y: randomY)
        
        // Sorteia o gesto que o balão vai exigir
        let requiredGesture: HandGesture = Bool.random() ? .openHand : .fist
        
        let balloon = Balloon(position: position, requiredGesture: requiredGesture)
        session.activeBalloons.append(balloon)
    }
    
    func processGesture(_ gesture: HandGesture) {
        guard session.isPlaying, gesture != .unknown else { return }
        
        // Busca o primeiro balão ativo (não estourado) que exige o gesto feito
        if let index = session.activeBalloons.firstIndex(where: { !$0.isPopped && $0.requiredGesture == gesture }) {
            // Acertou o gesto e estourou o balão
            session.activeBalloons[index].isPopped = true
            session.score += 10
            
            let poppedId = session.activeBalloons[index].id
            
            // Remove da tela após um tempo curto para permitir animação de "estouro"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.session.activeBalloons.removeAll(where: { $0.id == poppedId })
            }
        }
    }
    
    func endGame() {
        session.isPlaying = false
        visionService.stop()
        
        spawnTimer?.invalidate()
        spawnTimer = nil
        
        // Persistir a pontuação para a Siri (AppIntents) conseguir ler depois
        UserDefaults.standard.set(session.score, forKey: "lastScore")
    }
}
