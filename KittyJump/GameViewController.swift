//
//  GameViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/9/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var homeView = SKView()
    var scene = GameScene()

    @IBOutlet weak var startBackground: UIView!
    
    @IBAction func startGame(_ sender: Any) {
        let startButton = sender as? UIButton
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        scene.isStart = true
        scene.scaleMode = .aspectFill
        homeView.presentScene(scene)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startBackground.backgroundColor = UIColor(red:0.16, green:0.50, blue:0.73, alpha:0.7)
        
        homeView = self.view as! SKView
        if homeView != nil {
            // Load the SKScene from 'GameScene.sks'
            scene = GameScene(fileNamed: "GameScene")!
            if scene != nil {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                scene.viewController = self
                homeView.presentScene(scene)
            }
            homeView.ignoresSiblingOrder = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        }
        else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
