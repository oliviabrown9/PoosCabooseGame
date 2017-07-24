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
import Flurry_iOS_SDK

class GameOverViewController: UIViewController, FlurryAdInterstitialDelegate{
    
    // Variable for advertisement
    let adInterstitial = FlurryAdInterstitial(space:"ADSPACE");
    
    // Variables for changing label text
    var lastNineScores = SharingManager.sharedInstance.lastScores
    let highScore = SharingManager.sharedInstance.highScore
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var mostRecentScore: UILabel!
    @IBOutlet weak var pastScores: UILabel!
    
    // Start over image
    @IBOutlet weak var startOver: UIImageView?
    
    func adInterstitialDidFetchAd(interstitialAd: FlurryAdInterstitial!) {
        // You can choose to present the ad as soon as it is received
        interstitialAd.present(with: self);
    }
    func adInterstitialDidRender(interstitialAd: FlurryAdInterstitial!) {
        
    }
    
    // Informs the app that a video associated with this ad has finished playing
    // Only present for rewarded & client-side rewarded ad spaces
    func adInterstitialVideoDidFinish(interstitialAd: FlurryAdInterstitial!) {
        
    }
    
    // Informational callback invoked when there is an ad error
    func adInterstitial(interstitialAd: FlurryAdInterstitial!, adError: FlurryAdError, errorDescription: NSError!) {
        // @param interstitialAd The interstitial ad object associated with the error
        // @param adError an enum that gives the reason for the error
        // @param errorDescription An error object that gives additional information on the cause of the ad error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (adInterstitial?.ready)! {
            print("show add")
            adInterstitial?.present(with: self);
        } else {
            print("fetching add")
            adInterstitial?.fetchAd();
        }
        
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
    
    func swiped(_ gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "toStore", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        adInterstitial?.adDelegate = self;
        adInterstitial?.fetchAd();
        
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
