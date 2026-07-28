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
    private var dayNightOverlayNode: SKSpriteNode!
    
    // Texturas Pré-carregadas para Alta Performance
    private var ufoTexture: SKTexture!
    private var cow1Textures: [SKTexture] = []
    private var sleepTextures: [SKTexture] = []
    private var brownCowTextures: [SKTexture] = []
    private var pigWalkTextures: [SKTexture] = []
    private var pigRestTextures: [SKTexture] = []
    
    // Lista de nós de animais no pasto
    private var cowNodes: [SKSpriteNode] = []
    
    // Mapeamento de abduções ativas na cena (Target ID -> Nós da cena)
    private struct AbductionNodeGroup {
        let ufoNode: SKSpriteNode
        let outerBeamNode: SKShapeNode
        let innerBeamNode: SKShapeNode
        let badgeNode: SKNode
        let cowNode: SKSpriteNode
        let originalCowPositionY: CGFloat
        let animalType: AnimalType
        var abductionTimer: Timer?
    }
    
    private enum AnimalType {
        case walkingCow
        case sleepingCow
        case brownCow
        case sleepingPig
        case walkingPig
    }
    
    private var activeNodesMap: [UUID: AbductionNodeGroup] = [:]
    
    weak var viewModel: CowsGameViewModel?
    static let nativeSize = CGSize(width: 1512, height: 850)
    
    private var spawnTimer: Timer?
    
    // MARK: - FPS & Monitoramento de Desempenho
    private var lastUpdateTime: TimeInterval = 0
    private var frameCount: Int = 0
    private var fpsAccumulator: TimeInterval = 0
    private(set) var currentFPS: Double = 60.0
    
    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        self.backgroundColor = SKColor(red: 0.35, green: 0.73, blue: 0.88, alpha: 1.0)
        
        view.showsFPS = true
        view.showsNodeCount = true
        
        addChild(gameLayer)
        
        preloadTextures()
        setupLayers()
        layoutScene()
        setupCloudParallax()
        setupCows()
        resetDayNightCycle()
        showMenuState()
    }
    
    // MARK: - Estado de Menu Decorativo Contínuo
    private var decorativeUFO: SKSpriteNode?
    
    func showMenuState() {
        if decorativeUFO == nil {
            setupDecorativeUFO()
        }
        decorativeUFO?.alpha = 0
        decorativeUFO?.run(SKAction.fadeIn(withDuration: 0.4))
    }
    
    func hideMenuState() {
        decorativeUFO?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
        decorativeUFO = nil
    }
    
    private func setupDecorativeUFO() {
        let ufo = SKSpriteNode(texture: ufoTexture)
        ufo.zPosition = 5
        ufo.setScale(0.85)
        ufo.position = CGPoint(x: 0, y: 230)
        
        let beamPath = CGMutablePath()
        beamPath.move(to: CGPoint(x: -28, y: -15))
        beamPath.addLine(to: CGPoint(x: 28, y: -15))
        beamPath.addLine(to: CGPoint(x: 110, y: -440))
        beamPath.addLine(to: CGPoint(x: -110, y: -440))
        beamPath.closeSubpath()
        
        let beamNode = SKShapeNode(path: beamPath)
        beamNode.fillColor = SKColor(red: 0.2, green: 0.95, blue: 1.0, alpha: 0.20)
        beamNode.strokeColor = .clear
        beamNode.lineWidth = 0
        beamNode.zPosition = -1
        ufo.addChild(beamNode)
        
        let pulseBeam = SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scaleX(to: 1.08, duration: 1.2),
                SKAction.fadeAlpha(to: 0.35, duration: 1.2)
            ]),
            SKAction.group([
                SKAction.scaleX(to: 0.92, duration: 1.2),
                SKAction.fadeAlpha(to: 0.15, duration: 1.2)
            ])
        ]))
        beamNode.run(pulseBeam)
        
        let hoverUp = SKAction.moveBy(x: 0, y: 16, duration: 2.0)
        hoverUp.timingMode = .easeInEaseOut
        let hoverDown = SKAction.moveBy(x: 0, y: -16, duration: 2.0)
        hoverDown.timingMode = .easeInEaseOut
        let hoverAction = SKAction.repeatForever(SKAction.sequence([hoverUp, hoverDown]))
        
        let tiltRight = SKAction.rotate(toAngle: 0.06, duration: 2.4)
        tiltRight.timingMode = .easeInEaseOut
        let tiltLeft = SKAction.rotate(toAngle: -0.06, duration: 2.4)
        tiltLeft.timingMode = .easeInEaseOut
        let tiltAction = SKAction.repeatForever(SKAction.sequence([tiltRight, tiltLeft]))
        
        ufo.run(SKAction.group([hoverAction, tiltAction]))
        gameLayer.addChild(ufo)
        decorativeUFO = ufo
    }
    
    // MARK: - Loop de Física & Tracking Dinâmico do OVNI
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        let instantFPS = deltaTime > 0 ? (1.0 / deltaTime) : 60.0
        
        frameCount += 1
        fpsAccumulator += deltaTime
        
        if fpsAccumulator >= 1.0 {
            currentFPS = Double(frameCount) / fpsAccumulator
            frameCount = 0
            fpsAccumulator = 0
        }
        
        if deltaTime > 0.025 {
            print("⚠️ [FRAME SPIKE LOG] Delta: \(String(format: "%.3f", deltaTime))s | FPS Instantâneo: \(String(format: "%.1f", instantFPS)) | OVNIs: \(activeNodesMap.count)")
        } else {
            print("⏱ [FRAME] Delta: \(String(format: "%.3f", deltaTime))s | FPS Instantâneo: \(String(format: "%.1f", instantFPS))")
        }
        
        // Ativação Dinâmica do Ciclo de Noite a partir de 1000 Pontos
        if let viewModel = viewModel, viewModel.score >= 1000, !isDayNightCycleActive {
            isDayNightCycleActive = true
            startSlowDayNightCycle()
        }
        
        // Target Tracking seguro via cópia de chaves
        let activeKeys = Array(activeNodesMap.keys)
        for key in activeKeys {
            if let group = activeNodesMap[key] {
                let cowCurrentX = group.cowNode.position.x
                let diffX = cowCurrentX - group.ufoNode.position.x
                group.ufoNode.position.x += diffX * 0.08
            }
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
        
        pigWalkTextures = (1...5).map {
            let tex = SKTexture(imageNamed: "PorcoAndando\($0)")
            tex.filteringMode = .nearest
            return tex
        }
        
        pigRestTextures = (1...12).map {
            let tex = SKTexture(imageNamed: "PorcoDeitado\($0)")
            tex.filteringMode = .nearest
            return tex
        }
        
        var allTex: [SKTexture] = [ufoTexture]
        allTex.append(contentsOf: cow1Textures)
        allTex.append(contentsOf: sleepTextures)
        allTex.append(contentsOf: brownCowTextures)
        allTex.append(contentsOf: pigWalkTextures)
        allTex.append(contentsOf: pigRestTextures)
        
        SKTexture.preload(allTex) {}
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
        
        dayNightOverlayNode = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.3, alpha: 0.0), size: CowsGameScene.nativeSize)
        dayNightOverlayNode.position = .zero
        dayNightOverlayNode.zPosition = 3.5
        gameLayer.addChild(dayNightOverlayNode)
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
    
    // MARK: - Ciclo Dinâmico de Dia e Noite
    private var isDayNightCycleActive = false
    
    private func resetDayNightCycle() {
        isDayNightCycleActive = false
        dayNightOverlayNode?.removeAllActions()
        dayNightOverlayNode?.color = SKColor(red: 0.05, green: 0.08, blue: 0.3, alpha: 0.0)
    }
    
    private func startSlowDayNightCycle() {
        guard dayNightOverlayNode != nil else { return }
        dayNightOverlayNode.removeAllActions()
        
        logEvent("🌅 Ciclo de Noite Iniciado (1000+ Pontos Alcançados!)")
        
        let toDusk = SKAction.customAction(withDuration: 45.0) { node, elapsedTime in
            let progress = elapsedTime / 45.0
            let color = SKColor(red: 0.6 * progress, green: 0.2 * progress, blue: 0.4 * progress, alpha: CGFloat(0.38 * progress))
            (node as? SKSpriteNode)?.color = color
        }
        
        let toNight = SKAction.customAction(withDuration: 45.0) { node, elapsedTime in
            let progress = elapsedTime / 45.0
            let r = 0.6 - (0.55 * progress)
            let g = 0.2 - (0.12 * progress)
            let b = 0.4 + (0.1 * progress)
            let a = 0.38 + (0.24 * progress)
            (node as? SKSpriteNode)?.color = SKColor(red: r, green: g, blue: b, alpha: CGFloat(a))
        }
        
        let nightHold = SKAction.wait(forDuration: 30.0)
        
        let toDay = SKAction.customAction(withDuration: 45.0) { node, elapsedTime in
            let progress = elapsedTime / 45.0
            let a = 0.62 * (1.0 - progress)
            (node as? SKSpriteNode)?.color = SKColor(red: 0.05, green: 0.08, blue: 0.3, alpha: CGFloat(a))
        }
        
        let dayHold = SKAction.wait(forDuration: 30.0)
        
        let fullCycle = SKAction.sequence([toDusk, toNight, nightHold, toDay, dayHold])
        dayNightOverlayNode.run(SKAction.repeatForever(fullCycle))
    }
    
    // MARK: - Animais Caminhando e Descansando no Pasto
    private func setupCows() {
        cowNodes.forEach { $0.removeFromParent() }
        cowNodes.removeAll()
        
        // 0: Vaca Malhada Caminhando
        if let firstTex = cow1Textures.first {
            let vaca1 = SKSpriteNode(texture: firstTex)
            vaca1.zPosition = 4
            vaca1.position = CGPoint(x: -450, y: -250)
            vaca1.run(SKAction.repeatForever(SKAction.animate(with: cow1Textures, timePerFrame: 0.18)))
            vaca1.run(makeWalkSequence(distance: 260, duration: 10.0, node: vaca1), withKey: "walkMovement")
            gameLayer.addChild(vaca1)
            cowNodes.append(vaca1)
        }
        
        // 1: Vaca Malhada Dormindo
        if let firstSleepTex = sleepTextures.first {
            let vaca2 = SKSpriteNode(texture: firstSleepTex)
            vaca2.zPosition = 4
            vaca2.position = CGPoint(x: -180, y: -260)
            vaca2.run(SKAction.repeatForever(SKAction.animate(with: sleepTextures, timePerFrame: 0.3)))
            gameLayer.addChild(vaca2)
            cowNodes.append(vaca2)
        }
        
        // 2: Porco Deitado Descansando
        if let firstPigRest = pigRestTextures.first {
            let porco1 = SKSpriteNode(texture: firstPigRest)
            porco1.zPosition = 4
            porco1.position = CGPoint(x: 80, y: -265)
            porco1.run(SKAction.repeatForever(SKAction.animate(with: pigRestTextures, timePerFrame: 0.25)))
            gameLayer.addChild(porco1)
            cowNodes.append(porco1)
        }
        
        // 3: Vaca Marrom Caminhando
        if let firstBrownTex = brownCowTextures.first {
            let vaca3 = SKSpriteNode(texture: firstBrownTex)
            vaca3.zPosition = 4
            vaca3.position = CGPoint(x: 320, y: -250)
            vaca3.xScale = -1.0
            vaca3.run(SKAction.repeatForever(SKAction.animate(with: brownCowTextures, timePerFrame: 0.18)))
            vaca3.run(makeWalkSequence(distance: -220, duration: 11.0, node: vaca3), withKey: "walkMovement")
            gameLayer.addChild(vaca3)
            cowNodes.append(vaca3)
        }
        
        // 4: Porco Andando
        if let firstPigWalk = pigWalkTextures.first {
            let porco2 = SKSpriteNode(texture: firstPigWalk)
            porco2.zPosition = 4
            porco2.position = CGPoint(x: 520, y: -255)
            porco2.xScale = -1.0
            porco2.run(SKAction.repeatForever(SKAction.animate(with: pigWalkTextures, timePerFrame: 0.16)))
            porco2.run(makeWalkSequence(distance: -200, duration: 9.0, node: porco2), withKey: "walkMovement")
            gameLayer.addChild(porco2)
            cowNodes.append(porco2)
        }
    }
    
    private func makeWalkSequence(distance: CGFloat, duration: TimeInterval, node: SKSpriteNode) -> SKAction {
        let move1 = SKAction.moveBy(x: distance, y: 0, duration: duration)
        let flip1 = SKAction.run { [weak node] in
            guard let node = node else { return }
            node.xScale = -node.xScale
        }
        let move2 = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let flip2 = SKAction.run { [weak node] in
            guard let node = node else { return }
            node.xScale = -node.xScale
        }
        return SKAction.repeatForever(SKAction.sequence([move1, flip1, move2, flip2]))
    }
    
    // MARK: - Spawning de OVNIs & Game Loop
    func startSpawningUFOs() {
        stopSpawningUFOs()
        
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
        clearAllUFOs()
    }
    
    private func clearAllUFOs() {
        let currentMap = activeNodesMap
        activeNodesMap.removeAll()
        
        for (_, group) in currentMap {
            group.abductionTimer?.invalidate()
            group.ufoNode.removeFromParent()
        }
        
        setupCows()
        resetDayNightCycle()
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
        
        // Identifica o tipo do animal para animações de pânico
        let animalType: AnimalType
        switch target.cowIndex {
        case 1: animalType = .sleepingCow
        case 2: animalType = .sleepingPig
        case 3: animalType = .brownCow
        case 4: animalType = .walkingPig
        default: animalType = .walkingCow
        }
        
        if animalType == .sleepingCow {
            cowNode.removeAllActions()
            cowNode.run(SKAction.repeatForever(SKAction.animate(with: cow1Textures, timePerFrame: 0.18)))
        } else if animalType == .sleepingPig {
            cowNode.removeAllActions()
            cowNode.run(SKAction.repeatForever(SKAction.animate(with: pigWalkTextures, timePerFrame: 0.16)))
        }
        
        // 1. Feixe Trator Externo Suave
        let outerPath = CGMutablePath()
        outerPath.move(to: CGPoint(x: -32, y: -15))
        outerPath.addLine(to: CGPoint(x: 32, y: -15))
        outerPath.addLine(to: CGPoint(x: 140, y: -480))
        outerPath.addLine(to: CGPoint(x: -140, y: -480))
        outerPath.closeSubpath()
        
        let outerBeamNode = SKShapeNode(path: outerPath)
        outerBeamNode.fillColor = SKColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 0.25)
        outerBeamNode.strokeColor = .clear
        outerBeamNode.lineWidth = 0
        outerBeamNode.zPosition = -2
        ufoNode.addChild(outerBeamNode)
        
        // 2. Feixe Trator Interno Suave
        let innerPath = CGMutablePath()
        innerPath.move(to: CGPoint(x: -16, y: -15))
        innerPath.addLine(to: CGPoint(x: 16, y: -15))
        innerPath.addLine(to: CGPoint(x: 80, y: -480))
        innerPath.addLine(to: CGPoint(x: -80, y: -480))
        innerPath.closeSubpath()
        
        let innerBeamNode = SKShapeNode(path: innerPath)
        innerBeamNode.fillColor = SKColor(red: 0.35, green: 1.0, blue: 0.55, alpha: 0.38)
        innerBeamNode.strokeColor = .clear
        innerBeamNode.lineWidth = 0
        innerBeamNode.zPosition = -1
        ufoNode.addChild(innerBeamNode)
        
        let pulseGroup = SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scaleX(to: 1.06, duration: 0.6),
                SKAction.fadeAlpha(to: 0.45, duration: 0.6)
            ]),
            SKAction.group([
                SKAction.scaleX(to: 0.94, duration: 0.6),
                SKAction.fadeAlpha(to: 0.18, duration: 0.6)
            ])
        ]))
        outerBeamNode.run(pulseGroup)
        
        let hoverUp = SKAction.moveBy(x: 0, y: 12, duration: 1.5)
        hoverUp.timingMode = .easeInEaseOut
        let hoverDown = SKAction.moveBy(x: 0, y: -12, duration: 1.5)
        hoverDown.timingMode = .easeInEaseOut
        let hoverAction = SKAction.repeatForever(SKAction.sequence([hoverUp, hoverDown]))
        
        let tiltRight = SKAction.rotate(toAngle: 0.05, duration: 1.8)
        tiltRight.timingMode = .easeInEaseOut
        let tiltLeft = SKAction.rotate(toAngle: -0.05, duration: 1.8)
        tiltLeft.timingMode = .easeInEaseOut
        let tiltAction = SKAction.repeatForever(SKAction.sequence([tiltRight, tiltLeft]))
        
        ufoNode.run(SKAction.group([hoverAction, tiltAction]), withKey: "ufoHoverAndTilt")
        
        let badgeContainer = SKNode()
        badgeContainer.position = CGPoint(x: 0, y: 75)
        
        let bgShape = SKShapeNode(circleOfRadius: 28)
        bgShape.fillColor = SKColor.black.withAlphaComponent(0.75)
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
            outerBeamNode: outerBeamNode,
            innerBeamNode: innerBeamNode,
            badgeNode: badgeContainer,
            cowNode: cowNode,
            originalCowPositionY: cowOrigPos.y,
            animalType: animalType,
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
    
    // MARK: - Resgate do Animal (Gesto Correto)
    func performRescue(targetId: UUID) {
        guard let group = activeNodesMap[targetId] else { return }
        
        logEvent("🎉 Resgate Efetuado com Sucesso")
        
        group.abductionTimer?.invalidate()
        group.cowNode.removeAction(forKey: "abductionLift")
        
        group.outerBeamNode.run(SKAction.fadeOut(withDuration: 0.3))
        group.innerBeamNode.run(SKAction.fadeOut(withDuration: 0.3))
        group.badgeNode.run(SKAction.fadeOut(withDuration: 0.3))
        
        let escapeAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 600, duration: 0.6),
            SKAction.removeFromParent()
        ])
        escapeAction.timingMode = .easeIn
        group.ufoNode.run(escapeAction)
        
        let animalType = group.animalType
        let cowNode = group.cowNode
        let origPosY = group.originalCowPositionY
        
        let dropAction = SKAction.sequence([
            SKAction.moveTo(y: origPosY, duration: 0.7),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                if animalType == .sleepingCow {
                    cowNode.removeAllActions()
                    cowNode.run(SKAction.repeatForever(SKAction.animate(with: self.sleepTextures, timePerFrame: 0.3)))
                } else if animalType == .sleepingPig {
                    cowNode.removeAllActions()
                    cowNode.run(SKAction.repeatForever(SKAction.animate(with: self.pigRestTextures, timePerFrame: 0.25)))
                }
            }
        ])
        dropAction.timingMode = .easeOut
        group.cowNode.run(dropAction)
        
        activeNodesMap.removeValue(forKey: targetId)
        viewModel?.onCowRescued(targetId: targetId)
    }
    
    // MARK: - Falha na Abdução (Tempo Esgotado)
    private func triggerCowAbducted(targetId: UUID) {
        guard let group = activeNodesMap[targetId] else { return }
        
        logEvent("💥 Tempo Esgotado: Animal Abduzido pelo OVNI")
        
        group.abductionTimer?.invalidate()
        group.cowNode.removeAction(forKey: "abductionLift")
        
        let animalType = group.animalType
        let cowNode = group.cowNode
        let origPosY = group.originalCowPositionY
        
        let cowDisappear = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.1, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ]),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                cowNode.position.y = origPosY
                cowNode.setScale(1.0)
                cowNode.alpha = 1.0
                if animalType == .sleepingCow {
                    cowNode.removeAllActions()
                    cowNode.run(SKAction.repeatForever(SKAction.animate(with: self.sleepTextures, timePerFrame: 0.3)))
                } else if animalType == .sleepingPig {
                    cowNode.removeAllActions()
                    cowNode.run(SKAction.repeatForever(SKAction.animate(with: self.pigRestTextures, timePerFrame: 0.25)))
                }
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
        
        if dayNightOverlayNode != nil {
            dayNightOverlayNode.size = targetSize
            dayNightOverlayNode.position = .zero
        }
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
