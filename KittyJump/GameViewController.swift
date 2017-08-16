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

var homeView = SKView()

var multiplier: Int = 1

class GameViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var animationEndImage: UIImageView!
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var tapView: UIView!
    
    // Variables to run game
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
            initView()
            startGameScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SharingManager.sharedInstance.catImageString == "trotterpoos" || SharingManager.sharedInstance.catImageString == "poosrate" {
            multiplier = 2
        }
        else if SharingManager.sharedInstance.catImageString == "properpoos" || SharingManager.sharedInstance.catImageString == "pepepoos" {
            multiplier = 3
        }
        else if SharingManager.sharedInstance.catImageString == "quapoos" || SharingManager.sharedInstance.catImageString == "winniepoos" {
            multiplier = 4
        }
        else if SharingManager.sharedInstance.catImageString == "pous" || SharingManager.sharedInstance.catImageString == "poosfieri" {
            multiplier = 5
        }
        else if SharingManager.sharedInstance.catImageString == "bootspoos" || SharingManager.sharedInstance.catImageString == "yoncepoos" {
            multiplier = 6
        }
        else if SharingManager.sharedInstance.catImageString == "trumpoos" || SharingManager.sharedInstance.catImageString == "yoncepoos" {
            multiplier = 10
        }
        else if SharingManager.sharedInstance.catImageString == "poos" {
            multiplier = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gifImageView.delegate = self
        
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        if SharingManager.sharedInstance.onboardingFinished == false {
            SharingManager.sharedInstance.onboardingFinished = true
            gifImageView.isHidden = true
            animationEndImage.isHidden = false
            animationEndImage.fadeOut()
            initView()
        }
        else {
            let gif = UIImage(gifName: "splash.gif")
            let gifManager = SwiftyGifManager(memoryLimit: 20)
            self.gifImageView.setGifImage(gif, manager: gifManager, loopCount: 1)
        
            let tap = UITapGestureRecognizer(target: self, action: #selector(gifDidLoop))
            tapView.addGestureRecognizer(tap)
        }
    }
    
    // Initial screen
    func initView() {
        tapView.isHidden = true
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
    func startGameScreen() {
        startButton?.isEnabled = false
        startButton?.isHidden = true
        startBackground?.isHidden = true
        
        scene.isStart = true
        
        let introSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "intro", ofType: "mp3")!)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: introSound as URL)
            backgroundMusicPlayer.delegate = self
            backgroundMusicPlayer.numberOfLoops = 0
            backgroundMusicPlayer.prepareToPlay()
            if (!soundState) {
            backgroundMusicPlayer.play()
            }
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
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSessionCategoryAmbient, with: AVAudioSessionCategoryOptions.mixWithOthers)
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: backgroundSound as URL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            if (!soundState) {
            backgroundMusicPlayer.play()
            }
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
        animationEndImage.isHidden = false
        animationEndImage.fadeOut()
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
