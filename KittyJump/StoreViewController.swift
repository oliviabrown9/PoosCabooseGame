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
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cornerCat: UIImageView!

    var confirm: Bool = false
    var coins = SharingManager.sharedInstance.lifetimeScore
    var cost: Int = 0
    var place: Int = 0
    var buyButton: UIButton? = nil
    var coin: UIImageView? = nil
    var itemTitle: String = ""
    
    var tryFirst: Bool = false
    var trySecond: Bool = false
    var tryThird: Bool = false
    var tryFourth: Bool = false
    
    @IBOutlet weak var fifthTryButton: UIButton!
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
        if coins >= 10 {
            fifthTryButton.alpha = 1
            fifthTryButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        confirm = true
        hideModal()
    }
    @IBAction func cancelPressed(_ sender: Any) {
        hideModal()
    }
    
    // Change display to use button
    func itemAlreadyPurchased(buyButton: UIButton, coin: UIImageView) {
        buyButton.setTitle("use", for: .normal)
        buyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        coin.isHidden = true
    }
    @IBAction func firstTry(_ sender: Any) {
        if tryFirst == true {
            tryFirst = false
        } else {
        tryFirst = true
        }
        updateCatImage()
    }
    @IBAction func secondTry(_ sender: Any) {
       if trySecond == true {
            trySecond = false
        } else {
            trySecond = true
        }
        updateCatImage()
    }
    @IBAction func thirdTry(_ sender: Any) {
        if tryThird == true {
            tryThird = false
        } else {
            tryThird = true
        }
        updateCatImage()
    }
    @IBAction func fourthTry(_ sender: Any) {
        if tryFourth == true {
            tryFourth = false
        } else {
            tryFourth = true
        }
        updateCatImage()
    }
    @IBAction func fifthTry(_ sender: Any) {
        if cornerCat.image != #imageLiteral(resourceName: "poos-poosrate") {
            cornerCat.image = #imageLiteral(resourceName: "poos-poosrate")
        } else {
            cornerCat.image = #imageLiteral(resourceName: "poosCorner")
        }
    }
    
    func updateCatImage() {
        if tryFirst && tryThird {
            if cornerCat.image == #imageLiteral(resourceName: "poos-monocle") || cornerCat.image == #imageLiteral(resourceName: "poos-monocle-mustache") {
                tryThird = false
            }
            else {
                tryFirst = false
            }
            updateCatImage()
        }
        else if trySecond && tryThird {
            if cornerCat.image == #imageLiteral(resourceName: "poos-monocle") || cornerCat.image == #imageLiteral(resourceName: "poos-monocle-mustache") {
                tryThird = false
            }
            else {
                trySecond = false
            }
            updateCatImage()
        }
        if tryFirst && !trySecond && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-shades")
        }
        else if tryFirst && trySecond && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-shades-chain")
        }
        else if tryFirst && trySecond && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-shades-chain-mustache")
        }
        else if tryFirst && !trySecond && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-shades-mustache")
        }
        else if !tryFirst && trySecond && !tryThird && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-chain")
        }
        else if !tryFirst && trySecond && !tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-chain-mustache")
        }
        else if !tryFirst && !trySecond && tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-monocle-mustache")
        }
        else if !tryFirst && !trySecond && tryThird && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-monocle")
        }
        else if !tryFirst && !trySecond && !tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-mustache")
        }
        else {
            cornerCat.image = #imageLiteral(resourceName: "poosCorner")
        }
    }
    
    // Buy or use items
    @IBOutlet weak var firstBuyButton: UIButton!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBAction func firstBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[0] == "inStore" {
            purchaseItem(price: 1, num: 0, button: firstBuyButton, image: firstCoin, title: "shades")
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var secondBuyButton: UIButton!
    @IBAction func secondBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[1] == "inStore" {
            purchaseItem(price: 2000, num: 1, button: secondBuyButton, image: secondCoin, title: "chain")
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 5000, num: 2, button: thirdBuyButton, image: thirdCoin, title: "monocle")
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var fourthCoin: UIImageView!
    @IBOutlet weak var fourthBuyButton: UIButton!
    @IBAction func fourthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 10000, num: 3, button: fourthBuyButton, image: fourthCoin, title: "mustache")
        }
        else {
            print("use")
        }
    }
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[4] == "inStore" {
            purchaseItem(price: 100000, num: 4, button: fifthBuyButton, image: fifthCoin, title: "?????")
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
    func purchaseItem(price: Int, num: Int, button: UIButton, image: UIImageView, title: String) {
        cost = price
        place = num
        buyButton = button
        coin = image
        itemTitle = title
        
        if cost <= coins {
            modalView.layer.cornerRadius = 15
            confirmButton.layer.cornerRadius = 20
            messageLabel.text = "Buy \(itemTitle) for \(cost) coins?"
            showModal()
        }
        else {
            // popup not enough coins - buy more?
//            modalView.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 93/255, blue: 172/255, alpha: 1)
            modalView.layer.cornerRadius = 15
            confirmButton.layer.cornerRadius = 20
            messageLabel.text = "Oops! You don't have enough coins. Would you like to buy more?"
            showModal()
        }
    }
    
    func showModal() {
        modalTopConstraint.constant += self.view.bounds.height
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.modalView.isHidden = false
            self.modalTopConstraint.constant -= self.view.bounds.height
            
            self.view.layoutIfNeeded()
        })
    }
    
    func hideModal() {
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.modalTopConstraint.constant += self.view.bounds.height
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            if finished {
                self.modalView.isHidden = true
                self.modalTopConstraint.constant -= self.view.bounds.height
            }
        })
        if confirm == true && coins >= cost {
            coins -= cost
            currentCoins.text = "\(coins)"
            SharingManager.sharedInstance.lifetimeScore = coins
            SharingManager.sharedInstance.itemStates[place] = "inCloset"
            itemAlreadyPurchased(buyButton: buyButton!, coin: coin!)
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
