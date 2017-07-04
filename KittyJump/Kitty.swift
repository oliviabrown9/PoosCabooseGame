//
//  Kitty.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class Kitty : SKSpriteNode {
    
    // Init
    init() {
        let texture = SKTexture(imageNamed: "kitty.png")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: texture.size().width/3, height: texture.size().height/3))
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
}
