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
    
    let items: [Int] = [0, 1, 2, 3, 4]
    
    @IBOutlet weak var startOver: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCoins.text = "\(coins)"
        
        for i in items {
            if SharingManager.sharedInstance.itemStates[i] == "inCloset" {
                if items[i] == 0 {
                    itemAlreadyPurchased(buyButton: firstBuyButton, coin: firstCoin, useButton: firstUseButton)
                }
                if items[i] == 1 {
                    itemAlreadyPurchased(buyButton: secondBuyButton, coin: secondCoin, useButton: secondUseButton)
                }
                if items[i] == 2 {
                    itemAlreadyPurchased(buyButton: thirdBuyButton, coin: thirdCoin, useButton: thirdUseButton)
                }
                if items[i] == 3 {
                    itemAlreadyPurchased(buyButton: fourthBuyButton, coin: fourthCoin, useButton: fourthUseButton)
                }
                if items[i] == 4 {
                    itemAlreadyPurchased(buyButton: fifthBuyButton, coin: fifthCoin, useButton: fifthUseButton)
                }
                
            }
        }
    }
    
    func itemAlreadyPurchased(buyButton: UIButton, coin: UIImageView, useButton: UIButton) {
        buyButton.isHidden = true
        buyButton.isEnabled = false
        coin.isHidden = true
        useButton.isHidden = false
        useButton.isEnabled = true
    }
    
    @IBOutlet weak var firstBuyButton: UIButton!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBOutlet weak var firstUseButton: UIButton!
    @IBAction func firstBuy(_ sender: Any) {
        purchaseItem(cost: 1, buyButton: firstBuyButton, coinImage: firstCoin, useButton: firstUseButton, place: 0)
    }
    @IBAction func useFirstItem(_ sender: Any) {
    }
    
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var secondBuyButton: UIButton!
    @IBOutlet weak var secondUseButton: UIButton!
    @IBAction func secondBuy(_ sender: Any) {
        purchaseItem(cost: 2000, buyButton: secondBuyButton, coinImage: secondCoin, useButton: secondUseButton, place: 1)
    }
    @IBAction func useSecondItem(_ sender: Any) {
    }
    
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBOutlet weak var thirdUseButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        purchaseItem(cost: 5000, buyButton: thirdBuyButton, coinImage: thirdCoin, useButton: thirdUseButton, place: 2)
    }
    @IBAction func useThirdItem(_ sender: Any) {
    }
    
    @IBOutlet weak var fourthCoin: UIImageView!
    @IBOutlet weak var fourthBuyButton: UIButton!
    @IBOutlet weak var fourthUseButton: UIButton!
    @IBAction func fourthBuy(_ sender: Any) {
        purchaseItem(cost: 10000, buyButton: fourthBuyButton, coinImage: fourthCoin, useButton: fourthUseButton, place: 3)
    }
    @IBAction func useFourthItem(_ sender: Any) {
    }
    
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBOutlet weak var fifthUseButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        purchaseItem(cost: 100000, buyButton: fifthBuyButton, coinImage: fifthCoin, useButton: fifthUseButton, place: 4)
    }
    @IBAction func useFifthItem(_ sender: Any) {
    }
    
    // Recognize if startOver image is tapped
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver.isUserInteractionEnabled = true
        startOver.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Try to buy something
    func purchaseItem(cost: Int, buyButton: UIButton, coinImage: UIImageView, useButton: UIButton, place: Int) {
        if cost <= coins {
            coins -= cost
            currentCoins.text = "\(coins)"
            SharingManager.sharedInstance.lifetimeScore = coins
            buyButton.isEnabled = false
            buyButton.isHidden = true
            coinImage.isHidden = true
            useButton.isHidden = false
            useButton.isEnabled = true
            SharingManager.sharedInstance.itemStates[place] = "inCloset"
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
