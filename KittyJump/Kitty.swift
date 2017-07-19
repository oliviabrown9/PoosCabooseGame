//
//  Kitty.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class Kitty: SKSpriteNode {
    
    enum kittyFlyingState {
        case normal
        case onUp
        case onDown
        case kill
    }
    
    let timeJumping: Double  = 0.3
    let hJumping: CGFloat = 150
    let hHJumping: CGFloat = 240
    
    var kittyFState : kittyFlyingState = .normal
    // Init
    init() {
        let texture = SKTexture(imageNamed: SharingManager.sharedInstance.catImageString)
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: texture.size().width/2, height: texture.size().height/2))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Kitty setup
    func setup() {
        name="Kitty"
        anchorPoint.x = 0.5
        anchorPoint.y = 0.5
        zPosition=2
        let centerPoint = CGPoint(x: self.size.width / 2 - (self.size.width * self.anchorPoint.x), y: self.size.height / 2 - (self.size.height * self.anchorPoint.y))
        
        physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2.5, center: centerPoint)
        
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        physicsBody!.restitution = 0
        physicsBody!.pinned = false
        physicsBody!.categoryBitMask = categoryKitty
        physicsBody!.contactTestBitMask = categoryBorder | categoryTrain | categoryWagon | categoryDeadline
        physicsBody!.collisionBitMask = categoryBorder | categoryTrain | categoryWagon | categoryDeadline
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.isDynamic = true
    }
    
    func runFlying()
    {
        let posy1 = self.position.y + hHJumping
        
        let posy2 = self.position.y + hJumping
        
        let actCallBack1 = SKAction.run {
            
            self.kittyFState = .onUp
            
            self.zPosition = 3
            
        }
        
        let actUp = SKAction.move(to: CGPoint(x: self.position.x,
                                              y: posy1),
                                  duration: timeJumping)
        
        let actCallBack2 = SKAction.run {
            
            self.kittyFState = .onDown
            
            self.zPosition = 2
            
        }
        
        let actDown = SKAction.move(to: CGPoint(x: self.position.x,
                                                y: posy2),
                                    duration: timeJumping)
        
        let actCallBack3 = SKAction.run {
            
            self.kittyFState = .kill
        }
        
        let actSeq1 = SKAction.sequence([actCallBack1, actUp, actCallBack2, actDown, actCallBack3])
        
        let actScalX = SKAction.scaleX(to: 0.8, duration: timeJumping)
        
        let actScalY = SKAction.scaleY(to: 1.2, duration: timeJumping)
        
        let actG1 = SKAction.group([actScalX, actScalY])
        
        let actScalXDown = SKAction.scaleX(to: 1.2, duration: timeJumping)
        
        let actScalYDown = SKAction.scaleY(to: 0.8, duration: timeJumping)
        
        let actG2 = SKAction.group([actScalXDown, actScalYDown])
        
        let actScalXN = SKAction.scaleX(to: 1.0, duration: timeJumping/2)
        
        let actScalYN = SKAction.scaleY(to: 1.0, duration: timeJumping/2)
        
        let actG3 = SKAction.group([actScalXN, actScalYN])
        
        let actCallBack4 = SKAction.run {
            
            self.kittyFState = .kill
        }
        
        let actScalS = SKAction.sequence([actG1, actG2, actG3, actCallBack4])
        
        let actGroup = SKAction.group([actSeq1, actScalS])
        
        self.run(actGroup)
        
    }
    
    func resetStateToNormal()
    {
        self.removeAllActions()
        
        self.kittyFState = .normal
        
        self.xScale = 1.0
        
        self.yScale = 1.0
        
    }
}
