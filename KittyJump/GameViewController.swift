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
import SwiftyGif

class GameViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    // Variables to run game
    var homeView = SKView()
    var scene = GameScene()
    var isReplayGame = false
    
    // Variables for start scree
    @IBOutlet weak var startBackground: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startGame(_ sender: Any) {
        startGameScreen()
    }
    
    // Unwind segue
    @IBAction func unwindToHomeView(sender: UIStoryboardSegue) {
        if isReplayGame {
            viewDidLoad()
            startGameScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gifImageView.delegate = self
        
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        
        let gif = UIImage(gifName: "splash.gif")
        let gifmanager = SwiftyGifManager(memoryLimit:20)
        self.gifImageView.setGifImage(gif, manager: gifmanager, loopCount: 1)
    }
    
    // Initial screen
    func initView(){
        
        startButton?.isEnabled = true
        startButton?.isHidden = false
        startBackground?.isHidden = false
        
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
    
    // Transition from start to game
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
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension GameViewController : SwiftyGifDelegate {
    
    func gifDidStart() {
        print("gifDidStart")
    }
    
    func gifDidLoop() {
        gifImageView.isHidden = true
        initView()
    }
}
