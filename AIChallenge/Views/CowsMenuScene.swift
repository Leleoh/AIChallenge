// Ref: docs/sdd/CowreML_MainMenu_Spec.md
import SpriteKit

class CowsMenuScene: SKScene {
    private let gameLayer = SKNode()
    
    private var ceuNode: SKSpriteNode!
    private var relevoNode: SKSpriteNode!
    private var pastoNode: SKSpriteNode!
    private var nuvensNode1: SKSpriteNode!
    private var nuvensNode2: SKSpriteNode!
    private var decorativeUFO: SKSpriteNode!
    
    private var ufoTexture: SKTexture!
    private var cow1Textures: [SKTexture] = []
    private var sleepTextures: [SKTexture] = []
    private var brownCowTextures: [SKTexture] = []
    
    static let nativeSize = CGSize(width: 1512, height: 850)
    
    override func didMove(to view: SKView) {
        self.anchorPoint = .zero
        self.backgroundColor = SKColor(red: 0.35, green: 0.73, blue: 0.88, alpha: 1.0)
        
        addChild(gameLayer)
        
        preloadTextures()
        setupLayers()
        layoutScene()
        setupCloudParallax()
        setupCows()
        setupDecorativeUFO()
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
        
        let width = CowsMenuScene.nativeSize.width
        let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: 80.0)
        let resetPos = SKAction.moveBy(x: width, y: 0, duration: 0.0)
        let sequence = SKAction.sequence([moveLeft, resetPos])
        let repeatAction = SKAction.repeatForever(sequence)
        
        nuvensNode1.run(repeatAction)
        nuvensNode2.run(repeatAction)
    }
    
    private func setupCows() {
        // Vaca Malhada Caminhando
        if let firstTex = cow1Textures.first {
            let vaca1 = SKSpriteNode(texture: firstTex)
            vaca1.zPosition = 4
            vaca1.position = CGPoint(x: -320, y: -250)
            vaca1.run(SKAction.repeatForever(SKAction.animate(with: cow1Textures, timePerFrame: 0.18)))
            vaca1.run(makeWalkSequence(distance: 260, duration: 11.0, node: vaca1))
            gameLayer.addChild(vaca1)
        }
        
        // Vaca Dormindo no Centro
        if let firstSleepTex = sleepTextures.first {
            let vaca2 = SKSpriteNode(texture: firstSleepTex)
            vaca2.zPosition = 4
            vaca2.position = CGPoint(x: 20, y: -260)
            vaca2.run(SKAction.repeatForever(SKAction.animate(with: sleepTextures, timePerFrame: 0.3)))
            gameLayer.addChild(vaca2)
        }
        
        // Vaca Marrom Caminhando
        if let firstBrownTex = brownCowTextures.first {
            let vaca3 = SKSpriteNode(texture: firstBrownTex)
            vaca3.zPosition = 4
            vaca3.position = CGPoint(x: 360, y: -250)
            vaca3.xScale = -1.0
            vaca3.run(SKAction.repeatForever(SKAction.animate(with: brownCowTextures, timePerFrame: 0.18)))
            vaca3.run(makeWalkSequence(distance: -240, duration: 12.0, node: vaca3))
            gameLayer.addChild(vaca3)
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
    
    private func setupDecorativeUFO() {
        decorativeUFO = SKSpriteNode(texture: ufoTexture)
        decorativeUFO.zPosition = 5
        decorativeUFO.setScale(0.85)
        decorativeUFO.position = CGPoint(x: 0, y: 230)
        
        // Feixe Trator Decorativo Suave
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
        decorativeUFO.addChild(beamNode)
        
        // Animação de Pulso do Feixe
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
        
        // Animação de Flutuação e Oscilação do OVNI
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
        
        decorativeUFO.run(SKAction.group([hoverAction, tiltAction]))
        gameLayer.addChild(decorativeUFO)
    }
    
    private func layoutScene() {
        guard ceuNode != nil else { return }
        let targetSize = CowsMenuScene.nativeSize
        
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
        
        let scaleX = self.size.width / CowsMenuScene.nativeSize.width
        let scaleY = self.size.height / CowsMenuScene.nativeSize.height
        
        let finalScale = max(scaleX, scaleY)
        gameLayer.setScale(finalScale)
        gameLayer.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    }
}
