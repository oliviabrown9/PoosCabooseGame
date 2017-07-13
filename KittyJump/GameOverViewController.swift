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

class GameOverViewController: UIViewController {
    
    // Variables for changing label text
    var lastNineScores = SharingManager.sharedInstance.lastScores
    let highScore = SharingManager.sharedInstance.highScore
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var mostRecentScore: UILabel!
    @IBOutlet weak var pastScores: UILabel!
    
    // Start over image
    @IBOutlet weak var startOver: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highScoreLabel.text = "Best: \(highScore)"
        // Setting text of labels to stored value
        mostRecentScore.text = "\(lastNineScores[0])"
        let stringArray = lastNineScores.map
        {
            String($0)
        }
        pastScores.text = stringArray.joined(separator: "  ")
    }
    
    // Recognize if startOver image is tapped
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver.isUserInteractionEnabled = true
        startOver.addGestureRecognizer(tapGestureRecognizer)
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
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
