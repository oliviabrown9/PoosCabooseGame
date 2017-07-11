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
    
    var useFirst: Bool = false
    var useSecond: Bool = false
    var useThird: Bool = false
    var useFourth: Bool = false
    var useFifth: Bool = false
    
    @IBOutlet weak var firstTryButton: UIButton!
    @IBOutlet weak var secondTryButton: UIButton!
    @IBOutlet weak var thirdTryButton: UIButton!
    @IBOutlet weak var fourthTryButton: UIButton!
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
        if coins >= 100000 {
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
    
    // Try on
    @IBAction func firstTry(_ sender: Any) {
        if tryFirst == true {
            tryFirst = false
            firstTryButton.setTitle("try on", for: .normal)
        } else {
        tryFirst = true
            firstTryButton.setTitle("take off", for: .normal)
        }
        updateCornerCat()
    }
    @IBAction func secondTry(_ sender: Any) {
       if trySecond == true {
            trySecond = false
            secondTryButton.setTitle("try on", for: .normal)
        } else {
            trySecond = true
            secondTryButton.setTitle("take off", for: .normal)
        }
        updateCornerCat()
    }
    @IBAction func thirdTry(_ sender: Any) {
        if tryThird == true {
            tryThird = false
            thirdTryButton.setTitle("try on", for: .normal)
        } else {
            tryThird = true
            thirdTryButton.setTitle("take off", for: .normal)
        }
        updateCornerCat()
    }
    @IBAction func fourthTry(_ sender: Any) {
        if tryFourth == true {
            tryFourth = false
            fourthTryButton.setTitle("try on", for: .normal)
        } else {
            tryFourth = true
            fourthTryButton.setTitle("take off", for: .normal)
        }
        updateCornerCat()
    }
    @IBAction func fifthTry(_ sender: Any) {
        if cornerCat.image != #imageLiteral(resourceName: "poos-poosrate") {
            cornerCat.image = #imageLiteral(resourceName: "poos-poosrate")
            fifthTryButton.setTitle("take off", for: .normal)
        } else {
            cornerCat.image = #imageLiteral(resourceName: "poosCorner")
            fifthTryButton.setTitle("try on", for: .normal)
        }
    }
    
    // Change cat image depending on try on selections
    func updateCornerCat() {
        
        // Switch first & third since they cannot be displayed at the same time
        if tryFirst && tryThird {
            if cornerCat.image == #imageLiteral(resourceName: "poos-monocle") || cornerCat.image == #imageLiteral(resourceName: "poos-monocle-mustache") {
                tryThird = false
            }
            else {
                tryFirst = false
            }
            updateCornerCat()
        }
        
        // Switch second & third since they cannot be displayed at the same time
        else if trySecond && tryThird {
            if cornerCat.image == #imageLiteral(resourceName: "poos-monocle") || cornerCat.image == #imageLiteral(resourceName: "poos-monocle-mustache") {
                tryThird = false
            }
            else {
                trySecond = false
            }
            updateCornerCat()
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
    
    func updateUsing() {
        
        // Switch first & third since they cannot be used at the same time
        if useFirst && useThird {
            if catImage == #imageLiteral(resourceName: "poos-monocle") || catImage == #imageLiteral(resourceName: "poos-monocle-mustache") {
                useThird = false
            }
            else {
                useFirst = false
            }
            updateUsing()
        }
            
        // Switch second & third since they cannot be displayed at the same time
        else if useSecond && useThird {
            if catImage == #imageLiteral(resourceName: "poos-monocle") || catImage == #imageLiteral(resourceName: "poos-monocle-mustache") {
                useThird = false
            }
            else {
                useSecond = false
            }
            updateUsing()
        }
        if useFirst && !useSecond && !useFourth {
            catImage = #imageLiteral(resourceName: "poos-shades")
        }
        else if useFirst && useSecond && !useFourth {
            catImage = #imageLiteral(resourceName: "poos-shades-chain")
        }
        else if useFirst && useSecond && useFourth {
            catImage = #imageLiteral(resourceName: "poos-shades-chain-mustache")
        }
        else if useFirst && !useSecond && useFourth {
            catImage = #imageLiteral(resourceName: "poos-shades-mustache")
        }
        else if !useFirst && useSecond && !useThird && !useFourth {
            catImage = #imageLiteral(resourceName: "poos-chain")
        }
        else if !useFirst && useSecond && !useThird && useFourth {
            catImage = #imageLiteral(resourceName: "poos-chain-mustache")
        }
        else if !useFirst && !useSecond && useThird && useFourth {
            catImage = #imageLiteral(resourceName: "poos-monocle-mustache")
        }
        else if !useFirst && !useSecond && useThird && !useFourth {
            catImage = #imageLiteral(resourceName: "poos-monocle")
        }
        else if !useFirst && !useSecond && !useThird && useFourth {
            catImage = #imageLiteral(resourceName: "poos-mustache")
        }
        else {
            catImage = #imageLiteral(resourceName: "poosCorner")
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
            if useFirst == false {
            useFirst = true
                print("using")
                firstBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useFirst = false
                firstBuyButton.setTitle("use", for: .normal)
                print("removed")
            }
            updateUsing()
        }
    }
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var secondBuyButton: UIButton!
    @IBAction func secondBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[1] == "inStore" {
            purchaseItem(price: 2000, num: 1, button: secondBuyButton, image: secondCoin, title: "chain")
        }
        else {
            if useSecond == false {
                useSecond = true
                secondBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useSecond = false
                secondBuyButton.setTitle("use", for: .normal)
            }
          updateUsing()
        }
    }
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 5000, num: 2, button: thirdBuyButton, image: thirdCoin, title: "monocle")
        }
        else {
            if useThird == false {
                useThird = true
                thirdBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useThird = false
                thirdBuyButton.setTitle("use", for: .normal)
            }
            updateUsing()
        }
    }
    @IBOutlet weak var fourthCoin: UIImageView!
    @IBOutlet weak var fourthBuyButton: UIButton!
    @IBAction func fourthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 10000, num: 3, button: fourthBuyButton, image: fourthCoin, title: "mustache")
        }
        else {
            if useFourth == false {
                useFourth = true
                fourthBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useFourth = false
                fourthBuyButton.setTitle("use", for: .normal)
            }
            updateUsing()
        }
    }
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[4] == "inStore" {
            purchaseItem(price: 100000, num: 4, button: fifthBuyButton, image: fifthCoin, title: "?????")
        }
        else {
            if useFifth == false {
                useFifth = true
                fifthBuyButton.setTitle("remove", for: .normal)
                catImage = #imageLiteral(resourceName: "poos-poosrate")
            }
            else {
                useFifth = false
                fifthBuyButton.setTitle("use", for: .normal)
                catImage = #imageLiteral(resourceName: "kitty")
            }
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
