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
    
    // Score number label
    static func createScoreTitle()  {
        scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.zPosition = 4
        scoreLabel.fontSize = 250
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
    }
    
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
    static func createHighScore()  {
        highScoreLabel = SKLabelNode(fontNamed: "Avenir")
        highScoreLabel.zPosition = 4
        highScoreLabel.text = "High Score: \(SharingManager.sharedInstance.highScore)"
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = UIColor.yellow
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.verticalAlignmentMode = .center
    }
}
