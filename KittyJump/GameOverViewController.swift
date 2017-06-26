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

    var homeView = SKView()
    var scene = GameScene()
    
    var lastNineScores = SharingManager.sharedInstance.lastScores
    let highScore = SharingManager.sharedInstance.highScore
    
    @IBOutlet weak var mostRecentScore: UILabel!
    @IBOutlet weak var one: UILabel!
    @IBOutlet weak var two: UILabel!
    @IBOutlet weak var three: UILabel!
    @IBOutlet weak var four: UILabel!
    @IBOutlet weak var five: UILabel!
    @IBOutlet weak var six: UILabel!
    @IBOutlet weak var seven: UILabel!
    @IBOutlet weak var eight: UILabel!
    @IBOutlet weak var nine: UILabel!

    @IBOutlet weak var startOver: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver.isUserInteractionEnabled = true
        startOver.addGestureRecognizer(tapGestureRecognizer)
        
        mostRecentScore.text = "\(lastNineScores[0])"
        one.text = "\(lastNineScores[0])"
        two.text = "\(lastNineScores[1])"
        three.text = "\(lastNineScores[2])"
        four.text = "\(lastNineScores[3])"
        five.text = "\(lastNineScores[4])"
        six.text = "\(lastNineScores[5])"
        seven.text = "\(lastNineScores[6])"
        eight.text = "\(lastNineScores[7])"
        nine.text = "\(lastNineScores[8])"
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        // Segues to start screen
        performSegue(withIdentifier: "toGame", sender: self)
        }
}
