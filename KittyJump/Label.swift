//
//  Label.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/13/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//  Information about the label used in the game play
//

import UIKit
import SpriteKit

class Label: SKLabelNode {
    
    static var scoreLabel = SKLabelNode()
    static var highScoreLabel = SKLabelNode()
    static var scoreLabelHelper = SKLabelNode()
    
    // Current Score text label
    static func createScoreHelper() {
        scoreLabelHelper = SKLabelNode(fontNamed: "Avenir")
        scoreLabelHelper.zPosition = 4
        scoreLabelHelper.text = "Current Score"
        scoreLabelHelper.fontSize = 30
        scoreLabelHelper.fontColor = UIColor.white
        scoreLabelHelper.horizontalAlignmentMode = .center
        scoreLabelHelper.verticalAlignmentMode = .center
        
    }
    
    // High score text & number label
    static func createHighScore() {
        highScoreLabel = SKLabelNode(fontNamed: "Avenir")
        highScoreLabel.zPosition = 4
        highScoreLabel.text = "Best: \(SharingManager.sharedInstance.highScore)"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
    }
}
