// Ref: docs/sdd/CowsAbduction_GameLoop_Spec.md
import SpriteKit

class CowsGameScene: SKScene {
    // 1. Container Principal de nós (Container Layer)
    private let gameLayer = SKNode()
    
    private var ceuNode: SKSpriteNode!
    private var relevoNode: SKSpriteNode!
    private var pastoNode: SKSpriteNode!
    private var nuvensNode1: SKSpriteNode!
    private var nuvensNode2: SKSpriteNode!
    
    // Texturas Pré-carregadas para Alta Performance
    private var ufoTexture: SKTexture!
    private var cow1Textures: [SKTexture] = []
    private var sleepTextures: [SKTexture] = []
    private var brownCowTextures: [SKTexture] = []
    
    // Lista de nós de vacas no pasto
    private var cowNodes: [SKSpriteNode] = []
    
    // Mapeamento de abduções ativas na cena (Target ID -> Nós da cena)
    private struct AbductionNodeGroup {
        let ufoNode: SKSpriteNode
        let beamNode: SKShapeNode
        let badgeNode: SKNode
        let cowNode: SKSpriteNode
        let originalCowPosition: CGPoint
        var abductionTimer: Timer?
    }
    
    private var activeNodesMap: [UUID: AbductionNodeGroup] = [:]
    
    weak var viewModel: CowsGameViewModel?
    static let nativeSize = CGSize(width: 1512, height: 850)
    
    private var spawnTimer: Timer?
    
    // MARK: - FPS & Monitoramento de Desempenho em Tempo Real
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0
    private var fpsAccumulator: TimeInterval = 0
    private(set) var currentFPS: Double = 60.0
    
    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        self.backgroundColor = SKColor(red: 0.35, green: 0.73, blue: 0.88, alpha: 1.0)
        
        // Habilita a exibição do FPS e número de nós diretamente na tela do SpriteKit
        view.showsFPS = true
        view.showsNodeCount = true
        
        addChild(gameLayer)
        
        preloadTextures()
        setupLayers()
        layoutScene()
        setupCloudParallax()
        setupCows()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        frameCount += 1
        fpsAccumulator += deltaTime
        
        if fpsAccumulator >= 1.0 {
            currentFPS = Double(frameCount) / fpsAccumulator
            frameCount = 0
            fpsAccumulator = 0
        }
    }
    
    private func logEvent(_ message: String) {
        let fpsStr = String(format: "%.1f", currentFPS)
        let activeUFOs = activeNodesMap.count
        print("⚡ [GAME EVENT] \(message) | FPS: \(fpsStr) | OVNIs Ativos: \(activeUFOs) | Nós: \(gameLayer.children.count)")
    }
    
    private func preloadTextures() {
        ufoTexture = SKTexture(imageNamed: "DiscoVoador")
        ufoTexture.filteringMode = .nearest
        
        cow1Textures = (1...5).map {
            let tex = SKTexture(imageNamed: "VacaMalhadaCaminhando\($0)")
            tex.filteringMode = .nearest
            return tex
        }
        
        sleepTextures = (1...6).map {
            let tex = SKTexture(imageNamed: "VacaMalhadaDormindo\($0)")
            tex.filteringMode = .nearest
            return tex
        }
        
        brownCowTextures = (1...5).map {
            let tex = SKTexture(imageNamed: "VacaMarromAndando\($0)")
            tex.filteringMode = .nearest
            return tex
        }
        
        SKTexture.preload([ufoTexture] + cow1Textures + sleepTextures + brownCowTextures) {}
    }
    
    private func setupLayers() {
        let ceuTex = SKTexture(imageNamed: "Ceu")
        ceuTex.filteringMode = .nearest
        ceuNode = SKSpriteNode(texture: ceuTex)
        ceuNode.zPosition = 0
        gameLayer.addChild(ceuNode)
        
        let cloudTex = SKTexture(imageNamed: "NuvensBranca")
        cloudTex.filteringMode = .nearest
        
        nuvensNode1 = SKSpriteNode(texture: cloudTex)
        nuvensNode1.zPosition = 1
        gameLayer.addChild(nuvensNode1)
        
        nuvensNode2 = SKSpriteNode(texture: cloudTex)
        nuvensNode2.zPosition = 1
        gameLayer.addChild(nuvensNode2)
        
        let relevoTex = SKTexture(imageNamed: "Relevo")
        relevoTex.filteringMode = .nearest
        relevoNode = SKSpriteNode(texture: relevoTex)
        relevoNode.zPosition = 2
        gameLayer.addChild(relevoNode)
        
        let pastoTex = SKTexture(imageNamed: "Pasto")
        pastoTex.filteringMode = .nearest
        pastoNode = SKSpriteNode(texture: pastoTex)
        pastoNode.zPosition = 3
        gameLayer.addChild(pastoNode)
    }
    
    private func setupCloudParallax() {
        guard nuvensNode1 != nil && nuvensNode2 != nil else { return }
        
        nuvensNode1.removeAllActions()
        nuvensNode2.removeAllActions()
        
        let width = CowsGameScene.nativeSize.width
        let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: 90.0)
        let resetPos = SKAction.moveBy(x: width, y: 0, duration: 0.0)
        let sequence = SKAction.sequence([moveLeft, resetPos])
        let repeatAction = SKAction.repeatForever(sequence)
        
        nuvensNode1.run(repeatAction)
        nuvensNode2.run(repeatAction)
    }
    
    private func setupCows() {
        cowNodes.forEach { $0.removeFromParent() }
        cowNodes.removeAll()
        
        // Vaca 1: Malhada Caminhando (Esquerda)
        if let firstTex = cow1Textures.first {
            let vaca1 = SKSpriteNode(texture: firstTex)
            vaca1.zPosition = 4
            vaca1.position = CGPoint(x: -350, y: -250)
            vaca1.run(SKAction.repeatForever(SKAction.animate(with: cow1Textures, timePerFrame: 0.2)))
            gameLayer.addChild(vaca1)
            cowNodes.append(vaca1)
        }
        
        // Vaca 2: Malhada Dormindo (Centro)
        if let firstSleepTex = sleepTextures.first {
            let vaca2 = SKSpriteNode(texture: firstSleepTex)
            vaca2.zPosition = 4
            vaca2.position = CGPoint(x: 0, y: -260)
            vaca2.run(SKAction.repeatForever(SKAction.animate(with: sleepTextures, timePerFrame: 0.3)))
            gameLayer.addChild(vaca2)
            cowNodes.append(vaca2)
        }
        
        // Vaca 3: Marrom Caminhando (Direita)
        if let firstBrownTex = brownCowTextures.first {
            let vaca3 = SKSpriteNode(texture: firstBrownTex)
            vaca3.zPosition = 4
            vaca3.position = CGPoint(x: 350, y: -250)
            vaca3.xScale = -1.0
            vaca3.run(SKAction.repeatForever(SKAction.animate(with: brownCowTextures, timePerFrame: 0.2)))
            gameLayer.addChild(vaca3)
            cowNodes.append(vaca3)
        }
    }
    
    // MARK: - Spawning de OVNIs & Game Loop
    func startSpawningUFOs() {
        stopSpawningUFOs()
        clearAllUFOs()
        
        logEvent("▶️ Spawner de OVNIs Iniciado")
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.spawnRandomAbduction()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.spawnRandomAbduction()
        }
    }
    
    func stopSpawningUFOs() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    private func clearAllUFOs() {
        for (_, group) in activeNodesMap {
            group.ufoNode.removeFromParent()
            group.abductionTimer?.invalidate()
        }
        activeNodesMap.removeAll()
        setupCows()
    }
    
    private func spawnRandomAbduction() {
        guard let viewModel = viewModel, viewModel.gameState == .playing else { return }
        
        let busyCowNodes = activeNodesMap.values.map { $0.cowNode }
        let availableCowIndices = cowNodes.enumerated().compactMap { (index, node) in
            busyCowNodes.contains(node) ? nil : index
        }
        
        guard let chosenCowIndex = availableCowIndices.randomElement() else { return }
        let cowNode = cowNodes[chosenCowIndex]
        
        guard let randomGesture = GestureType.allCases.randomElement() else { return }
        
        let targetId = UUID()
        let duration: TimeInterval = 4.5
        let target = AbductionTarget(
            id: targetId,
            gestureRequired: randomGesture,
            timeRemaining: duration,
            totalDuration: duration,
            cowIndex: chosenCowIndex
        )
        
        viewModel.registerAbduction(target)
        createAbductionNodes(for: target, cowNode: cowNode)
        
        logEvent("🛸 Novo OVNI Criado (Gesto: \(randomGesture.rawValue))")
    }
    
    private func createAbductionNodes(for target: AbductionTarget, cowNode: SKSpriteNode) {
        let ufoNode = SKSpriteNode(texture: ufoTexture)
        ufoNode.zPosition = 5
        ufoNode.setScale(0.8)
        
        let ufoTargetY: CGFloat = 220.0
        let cowOrigPos = cowNode.position
        ufoNode.position = CGPoint(x: cowOrigPos.x, y: 700.0)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -25, y: -15))
        path.addLine(to: CGPoint(x: 25, y: -15))
        path.addLine(to: CGPoint(x: 120, y: -480))
        path.addLine(to: CGPoint(x: -120, y: -480))
        path.closeSubpath()
        
        let beamNode = SKShapeNode(path: path)
        beamNode.fillColor = SKColor(red: 0.3, green: 0.95, blue: 0.8, alpha: 0.4)
        beamNode.strokeColor = SKColor(red: 0.4, green: 1.0, blue: 0.9, alpha: 0.75)
        beamNode.lineWidth = 2.0
        beamNode.zPosition = -1
        ufoNode.addChild(beamNode)
        
        let fadePulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.25, duration: 0.5),
            SKAction.fadeAlpha(to: 0.55, duration: 0.5)
        ]))
        beamNode.run(fadePulse)
        
        let badgeContainer = SKNode()
        badgeContainer.position = CGPoint(x: 0, y: 75)
        
        let bgShape = SKShapeNode(circleOfRadius: 28)
        bgShape.fillColor = SKColor.black.withAlphaComponent(0.7)
        bgShape.strokeColor = SKColor.cyan
        bgShape.lineWidth = 2.5
        badgeContainer.addChild(bgShape)
        
        let labelNode = SKLabelNode(text: gestureSymbol(for: target.gestureRequired))
        labelNode.fontName = "AvenirNext-Bold"
        labelNode.fontSize = 24
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        badgeContainer.addChild(labelNode)
        
        ufoNode.addChild(badgeContainer)
        gameLayer.addChild(ufoNode)
        
        let enterAction = SKAction.moveTo(y: ufoTargetY, duration: 0.8)
        enterAction.timingMode = .easeOut
        ufoNode.run(enterAction)
        
        let liftCowAction = SKAction.moveBy(x: 0, y: 260, duration: target.totalDuration)
        cowNode.run(liftCowAction, withKey: "abductionLift")
        
        let timer = Timer.scheduledTimer(withTimeInterval: target.totalDuration, repeats: false) { [weak self] _ in
            self?.triggerCowAbducted(targetId: target.id)
        }
        
        let group = AbductionNodeGroup(
            ufoNode: ufoNode,
            beamNode: beamNode,
            badgeNode: badgeContainer,
            cowNode: cowNode,
            originalCowPosition: cowOrigPos,
            abductionTimer: timer
        )
        
        activeNodesMap[target.id] = group
    }
    
    private func gestureSymbol(for gesture: GestureType) -> String {
        switch gesture {
        case .square: return "⏹"
        case .circle: return "⏺"
        case .triangle: return "▲"
        case .lineV: return "V"
        case .lineZ: return "Z"
        case .infinite: return "∞"
        }
    }
    
    // MARK: - Resgate da Vaca (Gesto Correto)
    func performRescue(targetId: UUID) {
        guard let group = activeNodesMap[targetId] else { return }
        
        logEvent("🎉 Resgate Efetuado com Sucesso")
        
        group.abductionTimer?.invalidate()
        group.cowNode.removeAction(forKey: "abductionLift")
        
        group.beamNode.run(SKAction.fadeOut(withDuration: 0.3))
        group.badgeNode.run(SKAction.fadeOut(withDuration: 0.3))
        
        let escapeAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 600, duration: 0.6),
            SKAction.removeFromParent()
        ])
        escapeAction.timingMode = .easeIn
        group.ufoNode.run(escapeAction)
        
        let dropAction = SKAction.moveTo(y: group.originalCowPosition.y, duration: 0.7)
        dropAction.timingMode = .easeOut
        group.cowNode.run(dropAction)
        
        activeNodesMap.removeValue(forKey: targetId)
        viewModel?.onCowRescued(targetId: targetId)
    }
    
    // MARK: - Falha na Abdução (Tempo Esgotado)
    private func triggerCowAbducted(targetId: UUID) {
        guard let group = activeNodesMap[targetId] else { return }
        
        logEvent("💥 Tempo Esgotado: Vaca Abduzida pelo OVNI")
        
        group.abductionTimer?.invalidate()
        group.cowNode.removeAction(forKey: "abductionLift")
        
        let cowNode = group.cowNode
        let origPos = group.originalCowPosition
        
        let cowDisappear = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.1, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.run {
                cowNode.position = origPos
                cowNode.setScale(1.0)
                cowNode.alpha = 1.0
            }
        ])
        group.cowNode.run(cowDisappear)
        
        let ufoFlyAway = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 800, duration: 0.5),
            SKAction.removeFromParent()
        ])
        group.ufoNode.run(ufoFlyAway)
        
        activeNodesMap.removeValue(forKey: targetId)
        viewModel?.onCowAbducted(targetId: targetId)
    }
    
    // MARK: - Posicionamento e Redimensionamento
    func layoutScene() {
        guard ceuNode != nil else { return }
        let targetSize = CowsGameScene.nativeSize
        
        ceuNode.size = targetSize
        ceuNode.position = .zero
        
        nuvensNode1.size = targetSize
        nuvensNode1.position = .zero
        
        nuvensNode2.size = targetSize
        nuvensNode2.position = CGPoint(x: targetSize.width, y: 0)
        
        relevoNode.size = targetSize
        relevoNode.position = .zero
        
        pastoNode.size = targetSize
        pastoNode.position = .zero
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard self.size.width > 0 && self.size.height > 0 else { return }
        
        let scaleX = self.size.width / CowsGameScene.nativeSize.width
        let scaleY = self.size.height / CowsGameScene.nativeSize.height
        
        let finalScale = max(scaleX, scaleY)
        gameLayer.setScale(finalScale)
        gameLayer.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    }
}
