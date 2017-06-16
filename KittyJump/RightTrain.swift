//
//  RightTrain.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class RightTrain : SKSpriteNode{
    
    // MARK: -Init
    init() {
        let texture = SKTexture(imageNamed: "trainrightfacing.png")
        
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
        
        let sCenterPoint = CGPoint(x: self.frame.minX + (100 / 2), y:-1)
        let bCenterPoint = CGPoint(x: self.frame.maxX - (490 / 2) , y:0)
        
        let leftSmallBox = SKPhysicsBody(rectangleOf :CGSize(width: 100, height: 45) , center:sCenterPoint )
 
        
        
        let rightBigBox = SKPhysicsBody(rectangleOf :CGSize(width: 490, height: 90) , center:bCenterPoint )
        

        
        physicsBody=SKPhysicsBody(bodies: [leftSmallBox,rightBigBox])
        
        
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        physicsBody!.restitution = 0
        physicsBody!.affectedByGravity = true
        physicsBody!.categoryBitMask = category_wagon
        physicsBody!.contactTestBitMask =  category_kitty
        physicsBody!.collisionBitMask = category_track | category_kitty
        
        physicsBody!.usesPreciseCollisionDetection = false
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = false

        
    }
    
}
