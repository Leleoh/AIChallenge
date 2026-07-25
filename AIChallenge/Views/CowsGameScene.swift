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
            vacaNode.setScale(2.0)
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
            vacaDormindoNode.setScale(3.0)
            gameLayer.addChild(vacaDormindoNode)
        }
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
            self?.vacaNode.xScale = -abs(self?.vacaNode.xScale ?? 3.0)
        }
        let moveLeft = SKAction.moveBy(x: -walkDistance, y: 0, duration: walkDuration)
        let flipRight = SKAction.run { [weak self] in
            self?.vacaNode.xScale = abs(self?.vacaNode.xScale ?? 3.0)
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
        
        // Animação contínua dos 6 frames de sono (cadência mais calma: 0.3s)
        let animateAction = SKAction.animate(with: sleepingTextures, timePerFrame: 0.3)
        let repeatAnimate = SKAction.repeatForever(animateAction)
        vacaDormindoNode.run(repeatAnimate, withKey: "cowSleepAnimation")
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
