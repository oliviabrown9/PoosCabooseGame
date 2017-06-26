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
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startGame(_ sender: Any) {
        genericStartGame()
    }
    
    func genericStartGame () {
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        scene.scaleMode = .aspectFill
        scene.isStart = true
        homeView.presentScene(scene)
        homeView.ignoresSiblingOrder = true
        self.view.gestureRecognizers?.removeAll()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startBackground.backgroundColor = UIColor(red:0.16, green:0.50, blue:0.73, alpha:0.7)
        
        homeView = self.view as! SKView
        
        // Load SKScene
        scene = GameScene(fileNamed: "GameScene")!
        
        // Set the scale mode to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        scene.viewController = self
        homeView.presentScene(scene)
        homeView.ignoresSiblingOrder = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.genericStartGame))
        
        view.addGestureRecognizer(tap)
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
