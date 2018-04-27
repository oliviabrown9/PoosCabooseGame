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
import StoreKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FacebookLogin
import FacebookCore

var removedAds: Bool = SharingManager.sharedInstance.didRemoveAds

class GameOverViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    var facebookId = "";
    
    var ref: DatabaseReference?
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var cornerImageView: UIImageView!
    // Variables for changing label text
    var highScore = SharingManager.sharedInstance.highScore
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var mostRecentScore: UILabel!
    @IBOutlet weak var pastScores: UILabel!
    
    // Start over image
    @IBOutlet weak var startOver: UIImageView?
    
    @IBOutlet weak var preferencesView: UIView!
    @IBOutlet weak var preferencesTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var darkenedView: UIView!
    @IBAction func removeAdButtonTapped(_ sender: Any) {
        for product in list {
            let prodID = product.productIdentifier
            if prodID == "org.pooscaboose.noads" {
                p = product
                buyProduct()
            }
        }
    }
    @IBAction func restoreButtonTapped(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        restorePurchasesButton.isEnabled = false
        restorePurchasesButton.alpha = 0.5
    }
    
    func buyProduct() {
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
        
    }
    @IBAction func cancelPreferences(_ sender: Any) {
        hidePreferencesView()
    }
    
    @IBAction func preferencesButtonTapped(_ sender: Any) {
        showPreferencesView()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        // Set the default sharing message.
        let message = "Check out this game! My high score is \(highScore)! Think you can beat that?"
        
        // Set the link to share.
        if let link = NSURL(string: "http://pooscaboose.com/download")
        {
            let objectsToShare = [message, link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"), UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    var showFirst: Bool = true
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let myProduct = response.products
        for product in myProduct {
            list.append(product)
        }
    }
    
    @IBOutlet weak var storeButton: UIButton!
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let prodID = t.payment.productIdentifier as String
            restorePurchasesButton.alpha = 0.5
            restorePurchasesButton.isEnabled = false
            
            switch prodID {
            case "org.pooscaboose.noads":
                removedAds = true
                SharingManager.sharedInstance.didRemoveAds = true
                removeAdsButton.alpha = 0.5
                removeAdsButton.isEnabled = false
            default:
                print("iap not found")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            
            switch trans.transactionState {
            case .purchased:
                
                let prodID = p.productIdentifier
                switch prodID {
                case "org.pooscaboose.noads":
                    removedAds = true
                    SharingManager.sharedInstance.didRemoveAds = true
                    removeAdsButton.isEnabled = false
                    removeAdsButton.alpha = 0.5
                default:
                    print("iap not found")
                }
                queue.finishTransaction(trans)
            case .failed:
                queue.finishTransaction(trans)
                break
            default:
                break
            }
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if playCount % 3 == 0 && removedAds == false && showFirst == true {
            interstitial.present(fromRootViewController: self)
            showFirst = false
        }
    }
    
    @objc func hidePreferencesView() {
        darkenedView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.preferencesTopConstraint.constant += self.view.bounds.height
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            if finished {
                self.preferencesView.isHidden = true
                self.preferencesTopConstraint.constant -= self.view.bounds.height
            }
        })
    }
    
    func showPreferencesView() {
        preferencesView.layer.cornerRadius = 20
        removeAdsButton.layer.cornerRadius = 22
        restorePurchasesButton.layer.cornerRadius = 22
        darkenedView.isHidden = false
        
        if removedAds == true {
            removeAdsButton.isEnabled = false
            removeAdsButton.alpha = 0.5
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hidePreferencesView))
        darkenedView.addGestureRecognizer(tap)
        
        preferencesTopConstraint.constant += self.view.bounds.height
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.preferencesView.isHidden = false
            self.preferencesTopConstraint.constant -= self.view.bounds.height
            self.view.layoutIfNeeded()
        })
    }
    
    @IBOutlet weak var cornerHeight: NSLayoutConstraint!
    
    func setCornerImage() {
        if SharingManager.sharedInstance.catImageString == "poos" {
            cornerImageView.image = #imageLiteral(resourceName: "cornerpoos")
            cornerHeight.constant = 161
        }
        else if SharingManager.sharedInstance.catImageString == "trotterpoos" {
            cornerImageView.image = #imageLiteral(resourceName: "trotterCorner")
            cornerHeight.constant = 193
        }
        else if SharingManager.sharedInstance.catImageString == "poosrate" {
            cornerImageView.image = #imageLiteral(resourceName: "pirateCorner")
            cornerHeight.constant = 163.5
        }
        else if SharingManager.sharedInstance.catImageString == "properpoos" {
            cornerImageView.image = #imageLiteral(resourceName: "properCorner")
            cornerHeight.constant = 176
        }
        else if SharingManager.sharedInstance.catImageString == "quapoos" {
            cornerImageView.image = #imageLiteral(resourceName: "quaCorner")
            cornerHeight.constant = 162
        }
        else if SharingManager.sharedInstance.catImageString == "pous" {
            cornerImageView.image = #imageLiteral(resourceName: "pousCorner")
            cornerHeight.constant = 156
        }
        else if SharingManager.sharedInstance.catImageString == "bootspoos" {
            cornerImageView.image = #imageLiteral(resourceName: "bootsCorner")
            cornerHeight.constant = 190
        }
        else if SharingManager.sharedInstance.catImageString == "trumpoos" {
            cornerImageView.image = #imageLiteral(resourceName: "trumpCorner")
            cornerHeight.constant = 161.4
        }
        else if SharingManager.sharedInstance.catImageString == "winniepoos" {
            cornerImageView.image = #imageLiteral(resourceName: "winnieCorner")
            cornerHeight.constant = 189
        }
        else if SharingManager.sharedInstance.catImageString == "yoncepoos" {
            cornerImageView.image = #imageLiteral(resourceName: "yonceCorner")
            cornerHeight.constant = 157.5
        }
        else if SharingManager.sharedInstance.catImageString == "fieripoos" {
            cornerImageView.image = #imageLiteral(resourceName: "fieriCorner")
            cornerHeight.constant = 167.1
        }
        else if SharingManager.sharedInstance.catImageString == "pepepoos" {
            cornerImageView.image = #imageLiteral(resourceName: "pepeCorner")
            cornerHeight.constant = 192
        }
        else if SharingManager.sharedInstance.catImageString == "elvispoosley" {
            cornerImageView.image = #imageLiteral(resourceName: "elvispoosCorner")
            cornerHeight.constant = 192
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setCornerImage()
    }
    
    @objc func moveToStore() {
        performSegue(withIdentifier: "toStore", sender: self)
    }
    
    @objc func swipeToLeaderboard() {
        performSegue(withIdentifier: "toLeaderboard", sender: self)
    }

    @objc func swipeDownToPlay() {
        performSegue(withIdentifier: "unwindToHomeView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeButton.adjustsImageWhenHighlighted = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        startOver?.isUserInteractionEnabled = true
        startOver?.addGestureRecognizer(tapGestureRecognizer)
        
        let catTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(moveToStore))
        cornerImageView?.isUserInteractionEnabled = true
        cornerImageView?.addGestureRecognizer(catTapGestureRecognizer)
        
        if playCount % 3 == 0 {
            startOver?.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.startOver?.isUserInteractionEnabled = true
            }
        }
        
        ref = Database.database().reference()
        itemStates = SharingManager.sharedInstance.itemStates
        
        if(FBSDKAccessToken.current() != nil) {
        facebookId = FBSDKAccessToken.current().userID;
        updateCoins()
        }
        interstitial = createAndLoadInterstitial()
        
        if(self.facebookId != "" ){
        self.ref?.child("players").child(self.facebookId).updateChildValues(["highScore": self.highScore])
        self.ref?.child("players").child(facebookId).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
            //read the user data from the snapshot and do whatever with it
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let key = child.key ;
                    if(key.contains("score")){
                        let dbhighScore = child.value as! Int;
                        
                        if(dbhighScore < Int(SharingManager.sharedInstance.currentScore)){
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "dd-MM-yyyy"
                            let dateString = formatter.string(from:Date())
                            self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["score": SharingManager.sharedInstance.currentScore])
                            self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["date": dateString])
                        }
                    }
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
        if playCount % 3 != 0{
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
        
        if(SKPaymentQueue.canMakePayments()) {
            let productID: NSSet = NSSet(object: "org.pooscaboose.noads")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            request.delegate = self
            request.start()
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameOverViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToLeaderboard))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownToPlay))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let firstWord: String = NSLocalizedString("Best", comment: "best score")
        highScoreLabel.text = "\(firstWord): \(highScore)"
        mostRecentScore.text = "\(SharingManager.sharedInstance.currentScore)"
        // Setting text of labels to stored value
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
    
    @objc func swiped(_ gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "toStore", sender: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    // Unwind segue back to gameView
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
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
    
    func updateCoins(){
        if(facebookId != ""){
            ref?.child("players").child(facebookId).child("poosesOwned").observeSingleEvent(of: .value, with: { (snapshot) in
                //read the user data from the snapshot and do whatever with it
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        let index = Int(child.key)
                        let val = child.value as! String
                        if val == "inStore" {
                            itemStates[index!] = false
                        }
                        else if val == "inCloset" {
                            itemStates[index!] = true
                        }
                    }
                    SharingManager.sharedInstance.itemStates = itemStates
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}
