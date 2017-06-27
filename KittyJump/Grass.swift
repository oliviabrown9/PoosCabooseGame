//
//  Grass.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import SpriteKit

class Grass : SKSpriteNode {
    
    // Init
    init() {
        
        let texture = SKTexture(imageNamed: "grass.png")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 750, height: 100))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Grass setup
    func setup(){
        name="Grass"
        anchorPoint.x = 0
        anchorPoint.y = 0
        zPosition = -1
    }
}
