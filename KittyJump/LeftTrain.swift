//
//  LeftTrain.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class LeftTrain : SKSpriteNode{
    
    
    // MARK: -Init
    init() {
        let texture = SKTexture(imageNamed: "trainleftfacing.png")
        
        // super.init(texture : texture , color: UIColor.black, size: CGSize(width: 100, height: 45))
        super.init(texture : texture , color: UIColor.black, size: CGSize(width: 600, height: 90))
        setup()
        
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - custom function
    func setup(){
        alpha = 1
        zPosition = 1
         
        anchorPoint.x = 0.5
        
        anchorPoint.y = 0.5
        
        let bCenterPoint = CGPoint(x: self.frame.minX + (490 / 2) , y:0)
        
        let sCenterPoint = CGPoint(x: self.frame.maxX - (100 / 2), y:-1)

        
        let leftBigBox = SKPhysicsBody(rectangleOf :CGSize(width: 490, height: 90) , center:bCenterPoint )
        
        
        
        let rightSmallBox = SKPhysicsBody(rectangleOf :CGSize(width: 100, height: 45) , center:sCenterPoint )
    
        
        physicsBody=SKPhysicsBody(bodies: [leftBigBox,rightSmallBox])
        
        
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        physicsBody!.restitution = 0
        physicsBody!.affectedByGravity = true
        physicsBody!.categoryBitMask = category_train
        physicsBody!.collisionBitMask = category_kitty | category_track
        physicsBody!.contactTestBitMask = category_kitty
        
        physicsBody!.usesPreciseCollisionDetection = false
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = false

        
    }
    
    
}
