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
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer = AVAudioPlayer()

class GameViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    // Variables to run game
    var homeView = SKView()
    var scene = GameScene()
    var isReplayGame = false
    
    @IBOutlet weak var animationEndBackground: UIImageView!
    // Variables for start scree
    @IBOutlet weak var startBackground: UIView!
    var tapCount: Int = 0
    
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startGame(_ sender: Any) {
        startGameScreen()
    }
    
    // Unwind segue
    @IBAction func unwindToHomeView(sender: UIStoryboardSegue) {
        if isReplayGame {
            initView()
            startGameScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gifImageView.delegate = self
        
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        animationEndBackground?.isHidden = true
        
        let gif = UIImage(gifName: "splash.gif")
        let gifManager = SwiftyGifManager(memoryLimit:20)
        self.gifImageView.setGifImage(gif, manager: gifManager, loopCount: 1)
    }
    
    // Initial screen
    func initView(){
        
        startButton?.isEnabled = true
        startButton?.isHidden = false
        startBackground?.isHidden = false
//        animationEndBackground?.isHidden = true
        
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
        
        let introSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "intro", ofType: "mp3")!)
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: introSound as URL)
            backgroundMusicPlayer.delegate = self
            backgroundMusicPlayer.numberOfLoops = 1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch {
            print("Cannot play the file")
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        scene.viewController = self
        homeView.presentScene(scene)
        homeView.ignoresSiblingOrder = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let backgroundSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundSound as URL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch {
            print("Cannot play the file")
        }
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension GameViewController: SwiftyGifDelegate {
    
    func gifDidLoop() {
        gifImageView.isHidden = true
        animationEndBackground.isHidden = false
        animationEndBackground.fadeOut()
        initView()
    }
}
public extension UIView {
    func fadeOut(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func fadeIn(withDuration duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
}
