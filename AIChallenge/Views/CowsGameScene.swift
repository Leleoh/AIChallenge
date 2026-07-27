// Ref: docs/sdd/SpriteKit_CowsGame_Spec.md
import SpriteKit

class CowsGameScene: SKScene {
    // 1. Container Principal de nós (Container Layer)
    private let gameLayer = SKNode()
    
    private var ceuNode: SKSpriteNode!
    private var relevoNode: SKSpriteNode!
    private var pastoNode: SKSpriteNode!
    private var nuvensNode1: SKSpriteNode!
    private var nuvensNode2: SKSpriteNode!
    private var vacaNode: SKSpriteNode!
    private var vacaDormindoNode: SKSpriteNode!
    private var discoNode: SKSpriteNode!
    private var beamNode: SKShapeNode!
    
    static let nativeSize = CGSize(width: 1512, height: 850)
    
    override func didMove(to view: SKView) {
        // A âncora da cena fica no canto inferior esquerdo para facilitar a matemática
        self.anchorPoint = .zero
        self.backgroundColor = SKColor(red: 0.35, green: 0.73, blue: 0.88, alpha: 1.0)
        
        // Adiciona o container principal à cena
        addChild(gameLayer)
        
        setupLayers()
        layoutScene()
        setupCloudParallax()
        setupCowAnimation()
        setupSleepingCowAnimation()
        setupUFOAnimation()
        setupAbductionBeam()
    }
    
    private func setupLayers() {
        // Todas as camadas são adicionadas ao `gameLayer`
        
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
        
        // 5. Vaca Caminhando (Z: 4)
        var cowTextures: [SKTexture] = []
        for i in 1...5 {
            let tex = SKTexture(imageNamed: "VacaMalhadaCaminhando\(i)")
            tex.filteringMode = .nearest
            cowTextures.append(tex)
        }
        
        if let firstTex = cowTextures.first {
            vacaNode = SKSpriteNode(texture: firstTex)
            vacaNode.zPosition = 4
            vacaNode.setScale(1.0)
            gameLayer.addChild(vacaNode)
        }
        
        // 6. Vaca Dormindo (Z: 4)
        var sleepingTextures: [SKTexture] = []
        for i in 1...6 {
            let tex = SKTexture(imageNamed: "VacaMalhadaDormindo\(i)")
            tex.filteringMode = .nearest
            sleepingTextures.append(tex)
        }
        
        if let firstSleepTex = sleepingTextures.first {
            vacaDormindoNode = SKSpriteNode(texture: firstSleepTex)
            vacaDormindoNode.zPosition = 4
            vacaDormindoNode.setScale(1.0)
            gameLayer.addChild(vacaDormindoNode)
        }
        
        // 7. Disco Voador / OVNI (Z: 5)
        let discoTex = SKTexture(imageNamed: "DiscoVoador")
        discoTex.filteringMode = .nearest
        discoNode = SKSpriteNode(texture: discoTex)
        discoNode.zPosition = 5
        discoNode.setScale(0.8)
        gameLayer.addChild(discoNode)
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
    
    private func setupCowAnimation() {
        guard vacaNode != nil else { return }
        
        var cowTextures: [SKTexture] = []
        for i in 1...5 {
            let tex = SKTexture(imageNamed: "VacaMalhadaCaminhando\(i)")
            tex.filteringMode = .nearest
            cowTextures.append(tex)
        }
        
        let animateAction = SKAction.animate(with: cowTextures, timePerFrame: 0.15)
        let repeatAnimate = SKAction.repeatForever(animateAction)
        vacaNode.run(repeatAnimate, withKey: "cowWalkAnimation")
        
        let walkDistance: CGFloat = 350.0
        let walkDuration: TimeInterval = 12.0
        
        let moveRight = SKAction.moveBy(x: walkDistance, y: 0, duration: walkDuration)
        let flipLeft = SKAction.run { [weak self] in
            self?.vacaNode.xScale = -abs(self?.vacaNode.xScale ?? 1.0)
        }
        let moveLeft = SKAction.moveBy(x: -walkDistance, y: 0, duration: walkDuration)
        let flipRight = SKAction.run { [weak self] in
            self?.vacaNode.xScale = abs(self?.vacaNode.xScale ?? 1.0)
        }
        
        let walkSequence = SKAction.sequence([moveRight, flipLeft, moveLeft, flipRight])
        let repeatWalk = SKAction.repeatForever(walkSequence)
        vacaNode.run(repeatWalk, withKey: "cowMovement")
    }
    
    private func setupSleepingCowAnimation() {
        guard vacaDormindoNode != nil else { return }
        
        var sleepingTextures: [SKTexture] = []
        for i in 1...6 {
            let tex = SKTexture(imageNamed: "VacaMalhadaDormindo\(i)")
            tex.filteringMode = .nearest
            sleepingTextures.append(tex)
        }
        
        let animateAction = SKAction.animate(with: sleepingTextures, timePerFrame: 0.3)
        let repeatAnimate = SKAction.repeatForever(animateAction)
        vacaDormindoNode.run(repeatAnimate, withKey: "cowSleepAnimation")
    }
    
    private func setupUFOAnimation() {
        guard discoNode != nil else { return }
        
        // Animação Procedural 1: Efeito Pairar / Flutuação de Gravidade Zero
        let hoverUp = SKAction.moveBy(x: 0, y: 16, duration: 1.8)
        hoverUp.timingMode = .easeInEaseOut
        let hoverDown = SKAction.moveBy(x: 0, y: -16, duration: 1.8)
        hoverDown.timingMode = .easeInEaseOut
        let hoverSequence = SKAction.sequence([hoverUp, hoverDown])
        let repeatHover = SKAction.repeatForever(hoverSequence)
        
        // Animação Procedural 2: Inclinação sutil de flutuação no ar
        let tiltRight = SKAction.rotate(toAngle: 0.04, duration: 2.2)
        tiltRight.timingMode = .easeInEaseOut
        let tiltLeft = SKAction.rotate(toAngle: -0.04, duration: 2.2)
        tiltLeft.timingMode = .easeInEaseOut
        let tiltSequence = SKAction.sequence([tiltRight, tiltLeft])
        let repeatTilt = SKAction.repeatForever(tiltSequence)
        
        let groupAnimation = SKAction.group([repeatHover, repeatTilt])
        discoNode.run(groupAnimation, withKey: "ufoHover")
    }
    
    private func setupAbductionBeam() {
        guard discoNode != nil else { return }
        
        // Desenha um Feixe Trator de Abdução (Cone Neon Ciano/Verde)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -30, y: -20))
        path.addLine(to: CGPoint(x: 30, y: -20))
        path.addLine(to: CGPoint(x: 140, y: -450))
        path.addLine(to: CGPoint(x: -140, y: -450))
        path.closeSubpath()
        
        beamNode = SKShapeNode(path: path)
        beamNode.fillColor = SKColor(red: 0.3, green: 0.95, blue: 0.8, alpha: 0.35)
        beamNode.strokeColor = SKColor(red: 0.4, green: 1.0, blue: 0.9, alpha: 0.7)
        beamNode.lineWidth = 2.0
        beamNode.zPosition = -1 // Atrás da estrutura metálica do disco
        
        discoNode.addChild(beamNode)
        
        // Animação Neon de Pulso de Luz
        let fadeLess = SKAction.fadeAlpha(to: 0.2, duration: 0.7)
        let fadeMore = SKAction.fadeAlpha(to: 0.45, duration: 0.7)
        let pulseSequence = SKAction.sequence([fadeLess, fadeMore])
        let repeatPulse = SKAction.repeatForever(pulseSequence)
        beamNode.run(repeatPulse, withKey: "beamPulse")
    }
    
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
        
        // Vaca que anda (lado esquerdo do pasto)
        if vacaNode != nil {
            vacaNode.position = CGPoint(x: -200, y: -250)
        }
        
        // Vaca que dorme (lado direito do pasto, parada)
        if vacaDormindoNode != nil {
            vacaDormindoNode.position = CGPoint(x: 320, y: -260)
        }
        
        // Disco Voador pairando no céu sobre o centro-esquerdo
        if discoNode != nil {
            discoNode.position = CGPoint(x: 0, y: 180)
        }
    }
    
    // 2. A Matemática do Aspect Fill Manual (Pixels 100% Nítidos)
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
