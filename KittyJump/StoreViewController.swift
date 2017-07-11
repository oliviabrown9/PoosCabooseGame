//
//  StoreViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController {
    
    @IBOutlet weak var currentCoins: UILabel!
    
    var coins = SharingManager.sharedInstance.lifetimeScore
    
    @IBOutlet weak var startOver: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCoins.text = "\(coins)"
        
        // Change display if item previously purchased
        for i in 0...4 {
            if SharingManager.sharedInstance.itemStates[i] == "inCloset" {
                if i == 0 {
                    itemAlreadyPurchased(buyButton: firstBuyButton, coin: firstCoin)
                }
                if i == 1 {
                    itemAlreadyPurchased(buyButton: secondBuyButton, coin: secondCoin)
                }
                if i == 2 {
                    itemAlreadyPurchased(buyButton: thirdBuyButton, coin: thirdCoin)
                }
                if i == 3 {
                    itemAlreadyPurchased(buyButton: fourthBuyButton, coin: fourthCoin)
                }
                if i == 4 {
                    itemAlreadyPurchased(buyButton: fifthBuyButton, coin: fifthCoin)
                }
            }
        }
    }
    
    // Change display to use button
    func itemAlreadyPurchased(buyButton: UIButton, coin: UIImageView) {
        buyButton.setTitle("use", for: .normal)
        buyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        coin.isHidden = true
    }
    
    // Buy or use items
    @IBOutlet weak var firstBuyButton: UIButton!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBAction func firstBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[0] == "inStore" {
            purchaseItem(cost: 1, place: 0, buyButton: firstBuyButton, coin: firstCoin)
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var secondBuyButton: UIButton!
    @IBAction func secondBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[1] == "inStore" {
            purchaseItem(cost: 2000, place: 1, buyButton: secondBuyButton, coin: secondCoin)
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(cost: 5000, place: 2, buyButton: thirdBuyButton, coin: thirdCoin)
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var fourthCoin: UIImageView!
    @IBOutlet weak var fourthBuyButton: UIButton!
    @IBAction func fourthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(cost: 10000, place: 3, buyButton: fourthBuyButton, coin: fourthCoin)
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[4] == "inStore" {
            purchaseItem(cost: 100000, place: 4, buyButton: fifthBuyButton, coin: fifthCoin)
        }
        else {
            print("use")
        }
    }
    
    // Recognize if startOver image is tapped
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver.isUserInteractionEnabled = true
        startOver.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Try to buy something
    func purchaseItem(cost: Int, place: Int, buyButton: UIButton, coin: UIImageView) {
        if cost <= coins {
            coins -= cost
            currentCoins.text = "\(coins)"
            SharingManager.sharedInstance.lifetimeScore = coins
            SharingManager.sharedInstance.itemStates[place] = "inCloset"
            itemAlreadyPurchased(buyButton: buyButton, coin: coin)
        }
        else {
            // popup not enough coins - buy more?
        }
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
