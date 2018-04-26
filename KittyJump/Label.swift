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
        scoreLabelHelper = SKLabelNode(fontNamed: "Avenir-Black")
        scoreLabelHelper.zPosition = 4
        scoreLabelHelper.text = "Current Score"
        scoreLabelHelper.fontSize = 35
        scoreLabelHelper.fontColor = #colorLiteral(red: 0.7952535152, green: 0.7952535152, blue: 0.7952535152, alpha: 1)
        scoreLabelHelper.horizontalAlignmentMode = .center
        scoreLabelHelper.verticalAlignmentMode = .center
        
    }
    
    static var bestLocalized = NSLocalizedString("Best", comment: "Best")
    // High score text & number label
    static func createHighScore() {
        highScoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        highScoreLabel.zPosition = 4
        highScoreLabel.text = "\(bestLocalized): \(SharingManager.sharedInstance.highScore)"
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.verticalAlignmentMode = .center
    }
}
