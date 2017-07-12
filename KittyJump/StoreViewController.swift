//
//  StoreViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

var useFirst: Bool = SharingManager.sharedInstance.useFirst
var useSecond: Bool = false
var useThird: Bool = false
var useFourth: Bool = false
var useFifth: Bool = false

class StoreViewController: UIViewController {
    
    @IBOutlet weak var currentCoins: UILabel!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cornerCat: UIImageView!

    var confirm: Bool = false
//    var coins = SharingManager.sharedInstance.lifetimeScore
    var coins = 10000000
    var cost: Int = 0
    var place: Int = 0
    var buyButton: UIButton? = nil
    var coin: UIImageView? = nil
    var itemTitle: String = ""
    var use: Bool = false
    
    var tryFirst: Bool = false
    var trySecond: Bool = false
    var tryThird: Bool = false
    var tryFourth: Bool = false
    
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
                    itemAlreadyPurchased(buyButton: firstBuyButton, coin: firstCoin, use: useFirst)
                }
                if i == 1 {
                    itemAlreadyPurchased(buyButton: secondBuyButton, coin: secondCoin, use: useSecond)
                }
                if i == 2 {
                    itemAlreadyPurchased(buyButton: thirdBuyButton, coin: thirdCoin, use: useThird)
                }
                if i == 3 {
                    itemAlreadyPurchased(buyButton: fourthBuyButton, coin: fourthCoin, use: useFourth)
                }
                if i == 4 {
                    itemAlreadyPurchased(buyButton: fifthBuyButton, coin: fifthCoin, use: useFifth)
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
    func itemAlreadyPurchased(buyButton: UIButton, coin: UIImageView, use: Bool) {
        buyButton.setTitle("use", for: .normal)
        buyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        coin.isHidden = true
        
        if use == true {
            buyButton.setTitle("remove", for: .normal)
        }
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
            tryFirst = false
            trySecond = false
            tryThird = false
            tryFourth = false
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
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-shades")
        }
        else if tryFirst && trySecond && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-shades-chain")
        }
        else if tryFirst && trySecond && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "poos-shades-chain-mustache")
        }
        else if tryFirst && !trySecond && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-shades-mustache")
        }
        else if !tryFirst && trySecond && !tryThird && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-chain")
        }
        else if !tryFirst && trySecond && !tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-chain-mustache")
        }
        else if !tryFirst && !trySecond && tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-monocle-mustache")
        }
        else if !tryFirst && !trySecond && tryThird && !tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-monocle")
        }
        else if !tryFirst && !trySecond && !tryThird && tryFourth {
            cornerCat.image = #imageLiteral(resourceName: "cornerpoos-mustache")
        }
        else {
            cornerCat.image = #imageLiteral(resourceName: "poosCorner")
        }
    }
    
    func updateUsing() {
        
        // Switch first & third since they cannot be used at the same time
        if useFifth {
            if SharingManager.sharedInstance.catImageString == "poos-poosrate" {
                useFifth = false
                SharingManager.sharedInstance.useFifth = false
            }
            else {
                useFirst = false
                SharingManager.sharedInstance.useFirst = false
                useSecond = false
                SharingManager.sharedInstance.useSecond = false
                useThird = false
                SharingManager.sharedInstance.useThird = false
                useFourth = false
                SharingManager.sharedInstance.useFourth = false
            }
            updateUsing()
        }
        else if useFirst && useThird {
            if SharingManager.sharedInstance.catImageString == "poos-monocle" || SharingManager.sharedInstance.catImageString == "poos-monocle-mustache" {
                useThird = false
                SharingManager.sharedInstance.useThird = false
            }
            else {
                useFirst = false
                SharingManager.sharedInstance.useFirst = false
            }
            updateUsing()
        }
            
        // Switch second & third since they cannot be displayed at the same time
        else if useSecond && useThird {
            if SharingManager.sharedInstance.catImageString == "poos-monocle" || SharingManager.sharedInstance.catImageString == "poos-monocle-mustache" {
                useThird = false
                SharingManager.sharedInstance.useThird = false
            }
            else {
                useSecond = false
                SharingManager.sharedInstance.useSecond = false
            }
            updateUsing()
        }
        if useFirst && !useSecond && !useFourth {
            SharingManager.sharedInstance.catImageString = "poos-shades.png"
        }
        else if useFirst && useSecond && !useFourth {
            SharingManager.sharedInstance.catImageString = "poos-shades-chain"
        }
        else if useFirst && useSecond && useFourth {
            SharingManager.sharedInstance.catImageString = "poos-shades-chain-mustache"
        }
        else if useFirst && !useSecond && useFourth {
            SharingManager.sharedInstance.catImageString = "poos-shades-mustache"
        }
        else if !useFirst && useSecond && !useThird && !useFourth {
            SharingManager.sharedInstance.catImageString = "poos-chain"
        }
        else if !useFirst && useSecond && !useThird && useFourth {
            SharingManager.sharedInstance.catImageString = "poos-chain-mustache"
        }
        else if !useFirst && !useSecond && useThird && useFourth {
            SharingManager.sharedInstance.catImageString = "poos-monocle-mustache"
        }
        else if !useFirst && !useSecond && useThird && !useFourth {
            SharingManager.sharedInstance.catImageString = "poos-monocle"
        }
        else if !useFirst && !useSecond && !useThird && useFourth {
            SharingManager.sharedInstance.catImageString = "poos-mustache"
        }
        else if useFifth {
            SharingManager.sharedInstance.catImageString = "poos-poosrate"
        }
        else {
            SharingManager.sharedInstance.catImageString = "kitty"
        }
        updateButtons()
    }
    
    // Buy or use items
    @IBOutlet weak var firstBuyButton: UIButton!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBAction func firstBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[0] == "inStore" {
            purchaseItem(price: 1, num: 0, button: firstBuyButton, image: firstCoin, title: "shades", inUse: useFirst)
        }
        else {
            if useFirst == false {
            useFirst = true
            SharingManager.sharedInstance.useFirst = true
            }
            else {
                useFirst = false
                SharingManager.sharedInstance.useFirst = false
            }
            updateUsing()
        }
    }
    @IBOutlet weak var secondCoin: UIImageView!
    @IBOutlet weak var secondBuyButton: UIButton!
    @IBAction func secondBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[1] == "inStore" {
            purchaseItem(price: 2000, num: 1, button: secondBuyButton, image: secondCoin, title: "chain", inUse: useSecond)
        }
        else {
            if useSecond == false {
                useSecond = true
                SharingManager.sharedInstance.useSecond = true
            }
            else {
                useSecond = false
                SharingManager.sharedInstance.useSecond = false
            }
            updateUsing()
        }
    }
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 5000, num: 2, button: thirdBuyButton, image: thirdCoin, title: "monocle", inUse: useThird)
        }
        else {
            if useThird == false {
                useThird = true
                SharingManager.sharedInstance.useThird = true
            }
            else {
                useThird = false
                SharingManager.sharedInstance.useThird = false
            }
            updateUsing()
        }
    }
    @IBOutlet weak var fourthCoin: UIImageView!
    @IBOutlet weak var fourthBuyButton: UIButton!
    @IBAction func fourthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[3] == "inStore" {
            purchaseItem(price: 10000, num: 3, button: fourthBuyButton, image: fourthCoin, title: "mustache", inUse: useFourth)
        }
        else {
            if useFourth == false {
                useFourth = true
                SharingManager.sharedInstance.useFourth = true
            }
            else {
                useFourth = false
                SharingManager.sharedInstance.useFourth = false
            }
            updateUsing()
        }
    }
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[4] == "inStore" {
            purchaseItem(price: 100000, num: 4, button: fifthBuyButton, image: fifthCoin, title: "?????", inUse: useFifth)
        }
        else {
            if useFifth == false {
                useFifth = true
                SharingManager.sharedInstance.useFifth = true
                SharingManager.sharedInstance.catImageString = "poos-poosrate"
                updateButtons()
                
                
            }
            else {
                useFifth = false
                SharingManager.sharedInstance.useFifth = false
                SharingManager.sharedInstance.catImageString = "kitty"
                updateButtons()
            }
        }
    }
    
    func updateButtons() {
        if SharingManager.sharedInstance.useFirst == false {
            firstBuyButton.setTitle("use", for: .normal)
        }
        else {
            firstBuyButton.setTitle("remove", for: .normal)
        }
        if SharingManager.sharedInstance.useSecond == false {
            secondBuyButton.setTitle("use", for: .normal)
        }
        else {
            secondBuyButton.setTitle("remove", for: .normal)
        }
        if SharingManager.sharedInstance.useThird == false {
            thirdBuyButton.setTitle("use", for: .normal)
        }
        else {
            thirdBuyButton.setTitle("remove", for: .normal)
        }
        if SharingManager.sharedInstance.useFourth == false {
            fourthBuyButton.setTitle("use", for: .normal)
        }
        else {
            fourthBuyButton.setTitle("remove", for: .normal)
        }
        if SharingManager.sharedInstance.useFifth == false {
            fifthBuyButton.setTitle("use", for: .normal)
        }
        else {
            fifthBuyButton.setTitle("remove", for: .normal)
        }
    }
    
    // Recognize if startOver image is tapped
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver.isUserInteractionEnabled = true
        startOver.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Try to buy something
    func purchaseItem(price: Int, num: Int, button: UIButton, image: UIImageView, title: String, inUse: Bool) {
        cost = price
        place = num
        buyButton = button
        coin = image
        itemTitle = title
        use = inUse
        
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
            itemAlreadyPurchased(buyButton: buyButton!, coin: coin!, use: use)
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
