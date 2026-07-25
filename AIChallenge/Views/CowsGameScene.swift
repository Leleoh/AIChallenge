// Ref: docs/sdd/SpriteKit_CowsGame_Spec.md
import SpriteKit
import SwiftUI

class CowsGameScene: SKScene {
    private var ceuNode: SKSpriteNode!
    private var relevoNode: SKSpriteNode!
    private var pastoNode: SKSpriteNode!
    private var nuvensNode1: SKSpriteNode!
    private var nuvensNode2: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .black
        
        setupLayers()
        layoutScene()
        setupCloudParallax()
    }
    
    private func setupLayers() {
        // 1. Céu (Z: 0)
        ceuNode = SKSpriteNode(imageNamed: "Ceu")
        ceuNode.zPosition = 0
        addChild(ceuNode)
        
        // 2. Nuvens Brancas (Z: 1)
        nuvensNode1 = SKSpriteNode(imageNamed: "NuvensBranca")
        nuvensNode1.zPosition = 1
        addChild(nuvensNode1)
        
        nuvensNode2 = SKSpriteNode(imageNamed: "NuvensBranca")
        nuvensNode2.zPosition = 1
        addChild(nuvensNode2)
        
        // 3. Relevo / Montanhas (Z: 2)
        relevoNode = SKSpriteNode(imageNamed: "Relevo")
        relevoNode.zPosition = 2
        addChild(relevoNode)
        
        // 4. Pasto / Gramado (Z: 3)
        pastoNode = SKSpriteNode(imageNamed: "Pasto")
        pastoNode.zPosition = 3
        addChild(pastoNode)
    }
    
    private func setupCloudParallax() {
        nuvensNode1.removeAllActions()
        nuvensNode2.removeAllActions()
        
        let width = self.size.width > 0 ? self.size.width : 1000.0
        let moveLeft = SKAction.moveBy(x: -width, y: 0, duration: 40.0)
        let resetPos = SKAction.moveBy(x: width, y: 0, duration: 0.0)
        let sequence = SKAction.sequence([moveLeft, resetPos])
        let repeatAction = SKAction.repeatForever(sequence)
        
        nuvensNode1.run(repeatAction)
        nuvensNode2.run(repeatAction)
    }
    
    func layoutScene() {
        let w = self.size.width
        let h = self.size.height
        guard w > 0 && h > 0 else { return }
        
        // Como todos os PNGs já vêm do Figma exportados com o Canvas montado,
        // basta sobrepor todas as camadas no mesmo tamanho e centralizá-las em (0, 0)!
        
        let targetSize = CGSize(width: w, height: h)
        
        ceuNode.size = targetSize
        ceuNode.position = .zero
        
        nuvensNode1.size = targetSize
        nuvensNode1.position = .zero
        
        nuvensNode2.size = targetSize
        nuvensNode2.position = CGPoint(x: w, y: 0)
        
        relevoNode.size = targetSize
        relevoNode.position = .zero
        
        pastoNode.size = targetSize
        pastoNode.position = .zero
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard self.view != nil else { return }
        layoutScene()
        setupCloudParallax()
    }
}
