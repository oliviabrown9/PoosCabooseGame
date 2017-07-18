//
//  LeftTrain.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class LeftTrain : SKSpriteNode {
    
    var timeOfTrain : Double = 4.0
    
    // Init
    init() {
        let randomNum:UInt32 = arc4random_uniform(100)
        let trainnumber:Int = Int(randomNum)
        var str_trainname:String!
        var size_train:Int!
        switch (trainnumber % 6) {
        case 0:
            str_trainname = "trainleftfacing3.png"
            size_train = 480
        case 1:
            str_trainname = "trainleftfacing2.png"
            size_train = 360
        case 2:
            str_trainname = "trainleftfacing3.png"
            size_train = 480
        case 3:
            str_trainname = "trainleftfacing4.png"
            size_train = 600
        case 4:
            str_trainname = "trainleftfacing3.png"
            size_train = 480
        case 5:
            str_trainname = "trainleftfacing4.png"
            size_train = 600
        case 6:
            str_trainname = "trainleftfacing5.png"
            size_train = 720
        default:
            str_trainname = "trainleftfacing3.png"
            size_train = 480
        }
        let texture = SKTexture(imageNamed: str_trainname)
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: size_train, height: 90))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Left train setup
    func setup() {
        alpha = 1
        zPosition = 1
        
        anchorPoint.x = 0.5
        anchorPoint.y = 0.5
        
        let bCenterPoint = CGPoint(x: self.frame.minX + (490 / 2), y:0)
        let sCenterPoint = CGPoint(x: self.frame.maxX - (100 / 2), y:-1)
        let leftBigBox = SKPhysicsBody(rectangleOf :CGSize(width: 490, height: 90), center:bCenterPoint)
        let rightSmallBox = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 45), center: sCenterPoint)
        
        physicsBody=SKPhysicsBody(bodies: [leftBigBox,rightSmallBox])
        
        physicsBody!.allowsRotation = false
        physicsBody!.linearDamping = 0
        physicsBody!.restitution = 0
        physicsBody!.affectedByGravity = true
        physicsBody!.categoryBitMask = categoryTrain
        physicsBody!.collisionBitMask = categoryKitty | categoryTrack
        physicsBody!.contactTestBitMask = categoryKitty
        physicsBody!.usesPreciseCollisionDetection = false
        physicsBody!.isDynamic = true
        physicsBody!.affectedByGravity = false
    }
}
