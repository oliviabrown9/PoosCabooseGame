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
    var isReplayGame = false
    
    @IBOutlet weak var startBackground: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startGame(_ sender: Any) {
        startGameScreen()
    }
    
    @IBAction func unwindToHomeView(sender: UIStoryboardSegue) {
        if isReplayGame {
            viewDidLoad()
            startGameScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView(){
        startBackground.backgroundColor = UIColor(red:0.16, green:0.50, blue:0.73, alpha:0.7)
        
        homeView = self.view as! SKView
        
        // Load the SKScene from 'GameScene.sks'
        scene = GameScene(fileNamed: "GameScene")!
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        scene.viewController = self
        homeView.presentScene(scene)
        homeView.ignoresSiblingOrder = true
    }
    
    
    func startGameScreen(){
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        scene.isStart = true
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        scene.viewController = self
        homeView.presentScene(scene)
        homeView.ignoresSiblingOrder = true
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
