//
//  Deadline.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/18/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class Deadline : SKSpriteNode{
    
    // Init
    init() {
        let texture = SKTexture(imageNamed: "deadline")
        
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 750, height: 20))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Train setup
    func setup(){
        
        name="Deadline"
        anchorPoint.x = 0
        anchorPoint.y = 0
        zPosition = -1
        let centerPoint = CGPoint(x: self.size.width / 2 - (self.size.width * self.anchorPoint.x),y: self.size.height / 2 - (self.size.height * self.anchorPoint.y))
        
        physicsBody=SKPhysicsBody(rectangleOf:CGSize(width: 750*3, height: 20), center :centerPoint)
        
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        physicsBody!.restitution = 0
        physicsBody!.categoryBitMask = categoryDeadline
        physicsBody!.collisionBitMask = categoryKitty
        physicsBody!.usesPreciseCollisionDetection = true
        physicsBody!.isDynamic = false
        physicsBody!.affectedByGravity = false
    }
    
    static func getHeight() -> CGFloat{
        return 20
    }
}
