//
//  KCamera.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/14/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SpriteKit

class KCamera: SKCameraNode {
    
    public var kitty : SKSpriteNode!

      func createCamera(kitty:Kitty ,frameMax:CGFloat )  {
        
         
        let horizConstraint = SKConstraint.distance(SKRange(upperLimit: 0
        ), to: kitty)
        let vertConstraint = SKConstraint.distance(SKRange(upperLimit: 0), to: kitty)
        let leftConstraint = SKConstraint.positionX(SKRange(lowerLimit: 0))
        let bottomConstraint = SKConstraint.positionY(SKRange(lowerLimit: 0))
        let rightConstraint = SKConstraint.positionX(SKRange(upperLimit:0))
        let topConstraint = SKConstraint.positionY(SKRange(upperLimit: (frameMax*10)))//tBD self.frame.maxY
        
        //
        constraints = [horizConstraint, vertConstraint, leftConstraint , bottomConstraint, rightConstraint,topConstraint]
    
    }
    

}
