//
//  GameOverViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/24/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameOverViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    // Variables for changing label text
    var lastNineScores = SharingManager.sharedInstance.lastScores
    let highScore = SharingManager.sharedInstance.highScore
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var mostRecentScore: UILabel!
    @IBOutlet weak var pastScores: UILabel!
    
    // Start over image
    @IBOutlet weak var startOver: UIImageView?
    
    var showFirst: Bool = true
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if showFirst == true && playCount % 3 == 0 {
            interstitial.present(fromRootViewController: self)
            showFirst = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameOverViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        highScoreLabel.text = "Best: \(highScore)"
        // Setting text of labels to stored value
        mostRecentScore.text = "\(lastNineScores[0])"
        let stringArray = lastNineScores.map
        {
            String($0)
        }
        pastScores.text = stringArray.joined(separator: "  ")
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1224845211182149/4021005644")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func swiped(_ gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "toStore", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver?.isUserInteractionEnabled = true
        startOver?.addGestureRecognizer(tapGestureRecognizer)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    // Unwind segue back to gameView
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "unwindToHomeView", sender: self)
    }
    
    // Replay game with unwind segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToHomeView" {
            if let gameViewController = segue.destination as? GameViewController {
                gameViewController.isReplayGame = true
            }
        }
    }
    
    @IBAction func unwindToGameOver(sender: UIStoryboardSegue) {
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
