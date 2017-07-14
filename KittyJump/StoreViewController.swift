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

class StoreViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var currentCoins: UILabel!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var darkenedView: UIView!
    @IBOutlet weak var modalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var peek: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    var confirm: Bool = false
//    var coins = SharingManager.sharedInstance.lifetimeScore
    var coins = 1000000
    var cost: Int = 0
    var place: Int = 0
    var buyButton: UIButton? = nil
    var coin: UIImageView? = nil
    var itemTitle: String = ""
    var use: Bool = false
    
    // Connections for add coins popup
    @IBOutlet weak var addCoinsView: UIView!
    @IBOutlet weak var firstAddCoins: UIView!
    @IBOutlet weak var addCoinsLabel: UILabel!
    @IBOutlet weak var secondAddCoins: UIView!
    @IBOutlet weak var thirdAddCoins: UIView!
    @IBOutlet weak var fourthAddCoins: UIView!
    @IBOutlet weak var fifthAddCoins: UIView!
    @IBOutlet weak var addModalTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let slides: [Slide] = createSlides()
        setupScrollView(slides: slides)
        
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        
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
            // mysteries aren't mysteries?
        }
    }
    
    func createSlides() -> [Slide] {
        
        let slide1 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.image.image = #imageLiteral(resourceName: "poos")
        slide1.titleLabel.text = "OG Poos"
        slide1.costLabel.text = "Free"
        slide1.buyButton.layer.cornerRadius = 20
        slide1.buyButton.layer.borderWidth = 3
        slide1.buyButton.layer.borderColor = UIColor.white.cgColor
        let slide2 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.image.image = #imageLiteral(resourceName: "trotterpoos")
        let slide3 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.image.image = #imageLiteral(resourceName: "properpoos")
        let slide4 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.image.image = #imageLiteral(resourceName: "poosrate")
        let slide5 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide5.image.image = #imageLiteral(resourceName: "quapoos")
        let slide6 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide6.image.image = #imageLiteral(resourceName: "trumpoos")
        
        return [slide1, slide2, slide3, slide4, slide5, slide6]
    }
    
    func setupScrollView(slides: [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    @IBAction func confirmPressed(_ sender: Any) {
        confirm = true
        hideModal()
    }
    @IBAction func cancelPressed(_ sender: Any) {
        confirm = false
        hideModal()
    }
    
    // Change display to use button
    func itemAlreadyPurchased(buyButton: UIButton, coin: UIImageView, use: Bool) {
        buyButton.setTitle("use", for: .normal)
        coin.isHidden = true
        
        if use == true {
            buyButton.setTitle("remove", for: .normal)
        }
    }
    
    func updateUsing() {
        
        // new function will check pageIndex?
        
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
        else {
            SharingManager.sharedInstance.catImageString = "kitty"
        }
    }
    
    // Buy or use items
    @IBOutlet weak var firstBuyButton: UIButton!
    @IBOutlet weak var firstCoin: UIImageView!
    @IBAction func firstBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[0] == "inStore" {
            purchaseItem(price: 1000, num: 0, button: firstBuyButton, image: firstCoin, title: "shades", inUse: useFirst)
        }
        else {
            if useFirst == false {
            useFirst = true
            SharingManager.sharedInstance.useFirst = true
                print("using")
                firstBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useFirst = false
                SharingManager.sharedInstance.useFirst = false
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
            purchaseItem(price: 2000, num: 1, button: secondBuyButton, image: secondCoin, title: "chain", inUse: useSecond)
        }
        else {
            if useSecond == false {
                useSecond = true
                SharingManager.sharedInstance.useSecond = true
                secondBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useSecond = false
                SharingManager.sharedInstance.useSecond = false
                secondBuyButton.setTitle("use", for: .normal)
            }
          updateUsing()
        }
    }
    @IBOutlet weak var thirdCoin: UIImageView!
    @IBOutlet weak var thirdBuyButton: UIButton!
    @IBAction func thirdBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[2] == "inStore" {
            purchaseItem(price: 5000, num: 2, button: thirdBuyButton, image: thirdCoin, title: "monocle", inUse: useThird)
        }
        else {
            if useThird == false {
                useThird = true
                SharingManager.sharedInstance.useThird = true
                thirdBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useThird = false
                SharingManager.sharedInstance.useThird = false
                thirdBuyButton.setTitle("use", for: .normal)
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
                fourthBuyButton.setTitle("remove", for: .normal)
            }
            else {
                useFourth = false
                SharingManager.sharedInstance.useFourth = false
                fourthBuyButton.setTitle("use", for: .normal)
            }
            updateUsing()
        }
    }
    @IBOutlet weak var fifthCoin: UIImageView!
    @IBOutlet weak var fifthBuyButton: UIButton!
    @IBAction func fifthBuy(_ sender: Any) {
        if SharingManager.sharedInstance.itemStates[4] == "inStore" {
            purchaseItem(price: 100000, num: 4, button: fifthBuyButton, image: fifthCoin, title: "poosrate", inUse: useFifth)
            
        }
        else {
            if useFifth == false {
                useFifth = true
                SharingManager.sharedInstance.useFifth = true
                fifthBuyButton.setTitle("remove", for: .normal)
                SharingManager.sharedInstance.catImageString = "poos-poosrate"
            }
            else {
                useFifth = false
                SharingManager.sharedInstance.useFifth = false
                fifthBuyButton.setTitle("use", for: .normal)
                SharingManager.sharedInstance.catImageString = "kitty"
            }
        }
    }
    
    // Try to buy something
    func purchaseItem(price: Int, num: Int, button: UIButton, image: UIImageView, title: String, inUse: Bool) {
        let failureGenerator = UINotificationFeedbackGenerator()
        failureGenerator.prepare()
        
        cost = price
        place = num
        buyButton = button
        coin = image
        itemTitle = title
        use = inUse
        
        if cost <= coins {
            modalView.layer.cornerRadius = 20
            confirmButton.layer.cornerRadius = 25
            messageLabel.text = "Buy \(itemTitle) for \n \(cost) coins?"
            showModal()
        }
        else {
            failureGenerator.notificationOccurred(.error)
            modalView.layer.cornerRadius = 20
            confirmButton.layer.cornerRadius = 25
            messageLabel.text = "Poos... You don't have enough poos coin. Would you like to buy more?"
            showModal()
        }
    }
    
    
    func showModal() {
        
        darkenedView.isHidden = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        darkenedView.addGestureRecognizer(tap)
        
        modalTopConstraint.constant += self.view.bounds.height
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.modalView.isHidden = false
            self.modalTopConstraint.constant -= self.view.bounds.height
            self.view.layoutIfNeeded()
        })
    }
    
    func handleTap() {
        confirm = false
        hideModal()
        hideAddCoinsModal()
    }
    
    func hideModal() {
        view.layoutIfNeeded()
        
        if confirm == false {
            darkenedView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.modalTopConstraint.constant += self.view.bounds.height
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                if finished {
                    self.modalView.isHidden = true
                    self.modalTopConstraint.constant -= self.view.bounds.height
                }
            })
        }
        
        if confirm == true && coins >= cost {
            darkenedView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.modalTopConstraint.constant += self.view.bounds.height
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                if finished {
                    self.modalView.isHidden = true
                    self.modalTopConstraint.constant -= self.view.bounds.height
                }
            })
            
            coins -= cost
            currentCoins.text = "\(coins)"
            SharingManager.sharedInstance.lifetimeScore = coins
            SharingManager.sharedInstance.itemStates[place] = "inCloset"
            itemAlreadyPurchased(buyButton: buyButton!, coin: coin!, use: use)
        }
        else if confirm == true && cost >= coins {
            modalView.isHidden = true
            addCoinsView.layer.cornerRadius = 28
            addCoinsLabel.text = "Pick your poos coin \n package"
            peek.isHidden = false
            addCoinsView.isHidden = false
            addCoinsGestures()
        }
    }
    
    func addCoinsGestures() {

        let firstTap = UITapGestureRecognizer(target: self, action: #selector(buyCoins))
        firstAddCoins.addGestureRecognizer(firstTap)
        let secondTap = UITapGestureRecognizer(target: self, action: #selector(buyCoins))
        secondAddCoins.addGestureRecognizer(secondTap)
        let thirdTap = UITapGestureRecognizer(target: self, action: #selector(buyCoins))
        thirdAddCoins.addGestureRecognizer(thirdTap)
        let fourthTap = UITapGestureRecognizer(target: self, action: #selector(buyCoins))
        fourthAddCoins.addGestureRecognizer(fourthTap)
        let fifthTap = UITapGestureRecognizer(target: self, action: #selector(buyCoins))
        fifthAddCoins.addGestureRecognizer(fifthTap)
    }
    
    func hideAddCoinsModal() {
        view.layoutIfNeeded()
        darkenedView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.addModalTopConstraint.constant += self.view.bounds.height
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            if finished {
                self.addCoinsView.isHidden = true
                self.addModalTopConstraint.constant -= self.view.bounds.height
            }
        })
    }
   
    @IBAction func cancelAddCoins(_ sender: Any) {
        hideAddCoinsModal()
    }
    
    func buyCoins(_ recognizer:UITapGestureRecognizer) {
        
        let viewTapped = recognizer.view
        viewTapped?.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        
        let alertController = UIAlertController(title: "Oops!", message: "You can't buy things in beta!", preferredStyle: .alert)

        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            viewTapped?.backgroundColor = UIColor.white
            alertController.dismiss(animated: true, completion: nil)

        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
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
