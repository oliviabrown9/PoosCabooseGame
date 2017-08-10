//
//  Kitty.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit
import SpriteKitEasingSwift

class Kitty: SKSpriteNode {
    
    enum kittyFlyingState {
        case normal
        case onUp
        case onDown
        case kill
    }
    
    let timeJumping :   Double  = 0.1
    let hJumping :      CGFloat = 110
    let hHJumping :     CGFloat = 110
    
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
        let centerPoint = CGPoint(x: self.size.width / 2 - (self.size.width), y: self.size.height / 2 - (self.size.height * self.anchorPoint.y))
        
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
    
    func animateShape(destPos : CGPoint) {
        
        let destP = destPos
        
        self.run(SKEase.move(easeFunction: .curveTypeQuintic,
                             easeType: EaseType.easeTypeOut,
                             time: 0.2,
                             from: self.position ,
                             to: destP),
                 completion: { () -> Void in
                    finishJump = true
        })
    }
}
