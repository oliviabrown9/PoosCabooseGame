//
//  StoreViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import StoreKit
import SwiftyGif
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FacebookLogin
import FacebookCore

var using: Int = 0
var selectedPhoneNumber: String = ""
var itemStates: [String] = []
var facebookId = "";


class StoreViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, MFMessageComposeViewControllerDelegate {
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var currentCoins: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var darkenedView: UIView!
    @IBOutlet weak var modalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var peek: UIImageView!
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToGameOver", sender: self)
    }
    @IBOutlet weak var inviteFriendsView: UIView!
    @IBOutlet weak var unlockedLabel: UILabel!
   
    
    // Slides
    let slide0 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide1 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide2 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide3 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide4 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide5 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide6 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide7 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide8 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide9 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide10 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide11 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide12 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    
    @IBOutlet weak var scrollView: UIScrollView!
    var confirm: Bool = false
    var coins = SharingManager.sharedInstance.lifetimeScore
    var cost: Int = 0
    var buyButton: UIButton? = nil
    var coin: UIImageView? = nil
    var itemTitle: String = ""
    var use: Bool = false
    var pageIndex: Int = 0
    
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
    }
    

    
    @IBAction func moveViewLeftRight(sender: UIPageControl) {
        // Move to Right
        self.scrollView
            .scrollRectToVisible(CGRect(
                x: Int(self.scrollView.frame.size.width) * self.pageControl.currentPage,
                y: 0,
                width:Int(self.scrollView.frame.size.width),
                height: Int(self.scrollView.frame.size.height)),
                                 animated: true)

    }
    
    func updateCoins(){
        if(facebookId != ""){
            ref?.child("players").child(facebookId).child("poosesOwned").observeSingleEvent(of: .value, with: { (snapshot) in
                //read the user data from the snapshot and do whatever with it
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        let index = Int(child.key)
                        let val = child.value as! String
                        itemStates[index!] = val
                    }
                    self.updateUnlocked()
                    self.itemAlreadyPurchased()
                    SharingManager.sharedInstance.itemStates = itemStates
                    
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }else{
            
            self.updateUnlocked()
            self.itemAlreadyPurchased()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemStates = SharingManager.sharedInstance.itemStates
    }
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FBSDKAccessToken.current() != nil){
        facebookId = FBSDKAccessToken.current().userID;
        }
        ref = Database.database().reference()
        updateCoins();
        self.gifView.delegate = self
        
        //Add coin button click
        
        let addCoinBtnClick = UITapGestureRecognizer(target: self, action: #selector(animateAddCoinsView))
        coinImage.isUserInteractionEnabled = true
        coinImage.addGestureRecognizer(addCoinBtnClick)
        
        let slides: [Slide] = createSlides()
        setupScrollView(slides: slides)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        
        updateCoinsLabel()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.delegate = self
        self.view.addGestureRecognizer(swipeRight)
        
        if (SKPaymentQueue.canMakePayments()) {
            let productID: NSSet = NSSet(objects: "org.pooscaboose.onek", "org.pooscaboose.fivek", "org.pooscaboose.tenk", "org.pooscaboose.hundredk")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
        }
        else {
        }
        updateUnlocked()
        
    }
    
    let ofLocalized = NSLocalizedString("of", comment: "of")
    let unlockedLocalized = NSLocalizedString("unlocked", comment: "unlocked")
    
    func updateUnlocked() {
        var unlocked: Int = 0
        for i in itemStates {
            if i == "inCloset" {
                unlocked += 1
            }
        }
        let unlockedString: String = "\(unlocked) \(ofLocalized) 13 \(unlockedLocalized)"
        let attributedText = NSMutableAttributedString(string: unlockedString, attributes: [NSAttributedStringKey.font:UIFont(name: "Avenir-Medium", size: 18.0)!])
        if unlocked < 10 {
        attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black",size: 18.0)!, range: NSRange(location:0,length:1))
        attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black",size: 18.0)!, range: NSRange(location:6,length:1))
        }
        else {
            attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black",size: 18.0)!, range: NSRange(location:0,length:2))
            attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Avenir-Black",size: 18.0)!, range: NSRange(location:6,length:2))
        }
        unlockedLabel.attributedText = attributedText
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if pageIndex == 0 {
            performSegue(withIdentifier: "unwindToGameOver", sender: self)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    let inuseLocalized = NSLocalizedString("in use", comment: "in use")
    let useLocalized = NSLocalizedString("use", comment: "use")
    
    func buttonInUse(button: UIButton) {
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor(red:0.21, green:0.81, blue:0.85, alpha:1.0), for: .normal)
        button.setTitle("\(inuseLocalized)", for: .normal)
    }
    
    func buttonNotInUse(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("\(useLocalized)", for: .normal)
    }
    
    func setupInCloset(slide: Slide, x: Int) {
        slide.buyButton.isHidden = true
        slide.coinImage.isHidden = true
        slide.costLabel.isHidden = true
        slide.coinLabel.isHidden = true
        slide.useButton.isHidden = false
        if SharingManager.sharedInstance.using == x {
            buttonInUse(button: slide.useButton)
        }
        else {
            buttonNotInUse(button: slide.useButton)
        }
        slide.useButton.layer.cornerRadius = 20
        slide.useButton.layer.borderWidth = 3
        slide.useButton.layer.borderColor = UIColor.white.cgColor
        slide.useButton.addTarget(self, action: #selector(updateUsing), for: .touchUpInside)
    }
    
    func setupInStore(slide: Slide) {
        slide.useButton.isHidden = true
        slide.buyButton.layer.cornerRadius = 20
        slide.buyButton.layer.borderWidth = 3
        slide.buyButton.layer.borderColor = UIColor.white.cgColor
        slide.buyButton.addTarget(self, action: #selector(purchaseItem), for: .touchUpInside)
    }
    
    let multiplierLocalized = NSLocalizedString("coin multiplier", comment: "coin multiplier")
    
    func createSlides() -> [Slide] {
        
        let slideArray = [slide0, slide1, slide2, slide3, slide4, slide5, slide6, slide7, slide8, slide9, slide10, slide11, slide12]
        
        var x = 0
        for i in slideArray {
            if itemStates[x] == "inCloset" {
                setupInCloset(slide: i, x: x)
            }
            else {
                setupInStore(slide: i)
            }
            if x < slideArray.count {
                x += 1
            }
        }
        
        slide0.image.image = #imageLiteral(resourceName: "ogStore")
        slide0.titleLabel.text = "og poos"
        slide0.imageHeight.constant = 216
        slide0.multiplierLabel.text = "\(multiplierLocalized): 1x"
        
        slide1.image.image = #imageLiteral(resourceName: "trotterStore")
        slide1.titleLabel.text = "poos trotter"
        slide1.imageHeight.constant = 245
        slide1.multiplierLabel.text = "\(multiplierLocalized): 2x"
        slide1.costLabel.text = "1,000"
        
        slide2.image.image = #imageLiteral(resourceName: "rateStore")
        slide2.titleLabel.text = "pirate poos"
        slide2.imageHeight.constant = 217
        slide2.multiplierLabel.text = "\(multiplierLocalized): 2x"
        slide2.costLabel.text = "1,000"
        
        slide3.image.image = #imageLiteral(resourceName: "properStore")
        slide3.titleLabel.text = "proper poos"
        slide3.imageHeight.constant = 230
        slide3.multiplierLabel.text = "\(multiplierLocalized): 3x"
        slide3.costLabel.text = "2,000"
        
        slide4.image.image = #imageLiteral(resourceName: "pepeStore")
        slide4.titleLabel.text = "pepe le poos"
        slide4.imageHeight.constant = 242
        slide4.multiplierLabel.text = "\(multiplierLocalized): 3x"
        slide4.costLabel.text = "2,000"
        
        slide5.image.image = #imageLiteral(resourceName: "quaStore")
        slide5.titleLabel.text = "quapoos"
        slide5.imageHeight.constant = 217
        slide5.multiplierLabel.text = "\(multiplierLocalized): 4x"
        slide5.costLabel.text = "5,000"
        
        slide6.image.image = #imageLiteral(resourceName: "winnieStore")
        slide6.titleLabel.text = "winnie the poos"
        slide6.imageHeight.constant = 239
        slide6.multiplierLabel.text = "\(multiplierLocalized): 4x"
        slide6.costLabel.text = "5,000"
        
        slide7.image.image = #imageLiteral(resourceName: "pousStore")
        slide7.titleLabel.text = "le pous"
        slide7.imageHeight.constant = 208
        slide7.multiplierLabel.text = "\(multiplierLocalized): 5x"
        slide7.costLabel.text = "10,000"
        
        slide8.image.image = #imageLiteral(resourceName: "elvisStore")
        slide8.titleLabel.text = "elvis poosley"
        slide8.imageHeight.constant = 227
        slide8.multiplierLabel.text = "\(multiplierLocalized): 5x"
        slide8.costLabel.text = "10,000"
        
        slide9.image.image = #imageLiteral(resourceName: "fieriStore")
        slide9.titleLabel.text = "poos fieri"
        slide9.imageHeight.constant = 222
        slide9.multiplierLabel.text = "\(multiplierLocalized): 5x"
        slide9.costLabel.text = "10,000"
        
        slide10.image.image = #imageLiteral(resourceName: "bootsStore")
        slide10.titleLabel.text = "poos in boots"
        slide10.imageHeight.constant = 253
        slide10.multiplierLabel.text = "\(multiplierLocalized): 6x"
        slide10.costLabel.text = "25,000"
        
        slide11.image.image = #imageLiteral(resourceName: "yonceStore")
        slide11.titleLabel.text = "poosyoncé"
        slide11.imageHeight.constant = 195
        slide11.multiplierLabel.text = "\(multiplierLocalized): 6x"
        slide11.costLabel.text = "25,000"
        
        
        if coins >= 100000 {
            slide12.image.image = #imageLiteral(resourceName: "trumpStore")
            slide12.titleLabel.text = "trumpoos"
            slide12.imageHeight.constant = 216
            slide12.costLabel.text = "100,000"
        }
        else if itemStates[12] == "inCloset" {
            slide12.image.image = #imageLiteral(resourceName: "trumpStore")
            slide12.titleLabel.text = "trumpoos"
            slide12.imageHeight.constant = 216
        }
        else {
            slide12.image.image = #imageLiteral(resourceName: "mysteryStore")
            slide12.titleLabel.text = "?????"
            slide12.imageHeight.constant = 207
        }
        slide12.multiplierLabel.text = "\(multiplierLocalized): 10x"
        slide12.costLabel.text = "100,000"
        
        return [slide0, slide1, slide2, slide3, slide4, slide5, slide6, slide7, slide8, slide9, slide10, slide11, slide12]
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
        pageIndex = Int(round(scrollView.contentOffset.x/view.frame.width))
        pageControl.currentPage = pageIndex
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
    func itemAlreadyPurchased() {
        
        var currentSlide: Slide = slide0
        
        if pageIndex == 1 {
            currentSlide = slide1
        }
        else if pageIndex == 2 {
            currentSlide = slide2
        }
        else if pageIndex == 3 {
            currentSlide = slide3
        }
        else if pageIndex == 4 {
            currentSlide = slide4
        }
        else if pageIndex == 5 {
            currentSlide = slide5
        }
        else if pageIndex == 6 {
            currentSlide = slide6
        }
        else if pageIndex == 7 {
            currentSlide = slide7
        }
        else if pageIndex == 8 {
            currentSlide = slide8
        }
        else if pageIndex == 9 {
            currentSlide = slide9
        }
        else if pageIndex == 10 {
            currentSlide = slide10
        }
        else if pageIndex == 11 {
            currentSlide = slide11
        }
        else if pageIndex == 12 {
            currentSlide = slide12
        }
        setupInCloset(slide: currentSlide, x: pageIndex)
    }
    
    func updateUseButton() {
        let allSlides = [slide0, slide1, slide2, slide3, slide4, slide5, slide6, slide7, slide8, slide9, slide10, slide11, slide12]
        
        var x = 0
        for i in allSlides {
            if SharingManager.sharedInstance.using == x {
                buttonInUse(button: i.useButton)
            }
            else {
                if itemStates[x] == "inCloset" {
                    buttonNotInUse(button: i.useButton)
                }
                else {
                    buttonInUse(button: i.useButton)
                    
                }
            }
            x += 1
        }
    }
    
    @objc func updateUsing() {
        
        if pageIndex == 0 {
            SharingManager.sharedInstance.using = 0
            SharingManager.sharedInstance.catImageString = "poos"
            updateUseButton()
        }
        else if pageIndex == 1 {
            SharingManager.sharedInstance.using = 1
            SharingManager.sharedInstance.catImageString = "trotterpoos"
            updateUseButton()
        }
        else if pageIndex == 2 {
            SharingManager.sharedInstance.using = 2
            SharingManager.sharedInstance.catImageString = "poosrate"
            updateUseButton()
        }
        else if pageIndex == 3 {
            SharingManager.sharedInstance.using = 3
            SharingManager.sharedInstance.catImageString = "properpoos"
            updateUseButton()
        }
        else if pageIndex == 4 {
            SharingManager.sharedInstance.using = 4
            SharingManager.sharedInstance.catImageString = "pepepoos"
            updateUseButton()
        }
        else if pageIndex == 5 {
            SharingManager.sharedInstance.using = 5
            SharingManager.sharedInstance.catImageString = "quapoos"
            updateUseButton()
        }
        else if pageIndex == 6 {
            SharingManager.sharedInstance.using = 6
            SharingManager.sharedInstance.catImageString = "winniepoos"
            updateUseButton()
        }
        else if pageIndex == 7 {
            SharingManager.sharedInstance.using = 7
            SharingManager.sharedInstance.catImageString = "pous"
            updateUseButton()
        }
        else if pageIndex == 8 {
            SharingManager.sharedInstance.using = 8
            SharingManager.sharedInstance.catImageString = "elvispoosley"
            updateUseButton()
        }
        else if pageIndex == 9 {
            SharingManager.sharedInstance.using = 9
            SharingManager.sharedInstance.catImageString = "fieripoos"
            updateUseButton()
        }
        else if pageIndex == 10 {
            SharingManager.sharedInstance.using = 10
            SharingManager.sharedInstance.catImageString = "bootspoos"
            updateUseButton()
        }
        else if pageIndex == 11 {
            SharingManager.sharedInstance.using = 11
            SharingManager.sharedInstance.catImageString = "yoncepoos"
            updateUseButton()
        }
        else if pageIndex == 12 {
            SharingManager.sharedInstance.using = 12
            SharingManager.sharedInstance.catImageString = "trumpoos"
            updateUseButton()
        }
        performSegue(withIdentifier: "unwindToGameOver", sender: self)
    }
    
    // Try to buy something
    @objc func purchaseItem() {
        
        let failureGenerator = UINotificationFeedbackGenerator()
        failureGenerator.prepare()
        
        if pageIndex == 1 {
            itemTitle = "poos trotter"
            cost = 1000
        }
        else if pageIndex == 2 {
            itemTitle = "pirate poos"
            cost = 1000
        }
        else if pageIndex == 3 {
            itemTitle = "proper poos"
            cost = 2000
        }
        else if pageIndex == 4 {
            itemTitle = "pepe le poos"
            cost = 2000
        }
        else if pageIndex == 5 {
            itemTitle = "quapoos"
            cost = 5000
        }
        else if pageIndex == 6 {
            itemTitle = "winnie the poos"
            cost = 5000
        }
        else if pageIndex == 7 {
            itemTitle = "le pous"
            cost = 10000
        }
        else if pageIndex == 8 {
            itemTitle = "elvis poosley"
            cost = 10000
        }
        else if pageIndex == 9 {
            itemTitle = "poos fieri"
            cost = 10000
        }
        else if pageIndex == 10 {
            itemTitle = "poos in boots"
            cost = 25000
        }
        else if pageIndex == 11 {
            itemTitle = "poosyoncé"
            cost = 25000
        }
        else if pageIndex == 12 {
            itemTitle = "trumpoos"
            cost = 100000
        }
        
        if cost <= coins {
            modalView.layer.cornerRadius = 20
            confirmButton.layer.cornerRadius = 25
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedCost = numberFormatter.string(from: NSNumber(value:cost))
            messageLabel.text = "Buy \(itemTitle) for \n \(formattedCost!) coins?"
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
    
    @objc func handleTap() {
        confirm = false
        hideModal()
        hideAddCoinsModal()
        hideShareModal()
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
            
            updateCoinsLabel()
            SharingManager.sharedInstance.lifetimeScore = coins
            if(facebookId != ""){
            ref?.child("players").child(facebookId).child("poosesOwned").updateChildValues(["\(pageIndex)": "inCloset"])
                updateCoins();
            }
            else{
                SharingManager.sharedInstance.itemStates[pageIndex] = "inCloset";
                updateCoins();
            }
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
        else if confirm == true && cost >= coins {
            showAddCoinsView();
        }
    }
    
    let coinlabelLocalized = NSLocalizedString("Pick your poos coin \n package", comment: "pick your")
    
    func showAddCoinsView(){
        view.layoutIfNeeded()
        
        darkenedView.isHidden = false
        modalView.isHidden = true
        addCoinsView.layer.cornerRadius = 28
        addCoinsLabel.text = coinlabelLocalized
        peek.isHidden = false
        addCoinsView.isHidden = false
        addCoinsGestures()
    }
    
    @objc func animateAddCoinsView() {
        addCoinsView.layer.cornerRadius = 28
        addCoinsLabel.text = coinlabelLocalized
        
        darkenedView.isHidden = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        darkenedView.addGestureRecognizer(tap)
        
        addModalTopConstraint.constant += self.view.bounds.height
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.addCoinsView.isHidden = false
            self.addModalTopConstraint.constant -= self.view.bounds.height
            self.view.layoutIfNeeded()
        })
        addCoinsGestures()
    }
    
    func setPlaceHolder(placeholder: String)-> String {
        let text = placeholder
        if text.last! != " " {
            
            // define a max size
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 104, height: 40)
            // get the size of the text
            let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            // get the size of one space
            let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:nil, context:nil).size.width
            let spaces = floor((maxSize.width - widthText) / widthSpace)
            // add the spaces
            let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
            if newText != text {
                return newText
            }
        }
        return placeholder;
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func inviteFriends() {
        checkAuthorization()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        inviteFriendsView.addGestureRecognizer(tap)
        inviteFriendsView.layer.cornerRadius = 28
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.black
        textFieldInsideSearchBar?.font = UIFont(name: "Avenir-Medium", size: 18)
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string: self.setPlaceHolder(placeholder: "search"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
        let button = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        if let image = button.imageView?.image {
            button.setImage(image.transform(withNewColor: UIColor.black), for: .normal)
            if let imageView = textFieldInsideSearchBar?.leftView as? UIImageView {
                imageView.image = imageView.image?.transform(withNewColor: UIColor.black)
            }
        }
        
        inviteFriendsView.isHidden = false
    }
    
    func addCoinsGestures() {
        
        let firstTap = UITapGestureRecognizer(target: self, action: #selector(inviteFriends))
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
                self.peek.isHidden = true
            }
        })
    }
    
    @IBOutlet weak var shareTopConstraint: NSLayoutConstraint!
    
    func hideShareModal() {
        view.layoutIfNeeded()
        darkenedView.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.shareTopConstraint.constant += self.view.bounds.height
            self.view.endEditing(true)
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            if finished {
                self.inviteFriendsView.isHidden = true
                self.shareTopConstraint.constant -= self.view.bounds.height
                self.peek.isHidden = true
            }
        })
    }
    
    @IBAction func cancelShare(_ sender: Any) {
        hideShareModal()
    }
    
    @IBAction func cancelAddCoins(_ sender: Any) {
        hideAddCoinsModal()
    }
    
    @objc func buyCoins(_ recognizer: UITapGestureRecognizer) {
        
        let viewTapped = recognizer.view
        viewTapped?.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        
        if viewTapped == secondAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "org.pooscaboose.onek" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == thirdAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "org.pooscaboose.fivek" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == fourthAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "org.pooscaboose.tenk" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == fifthAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "org.pooscaboose.hundredk" {
                    p = product
                    buyProduct()
                }
            }
        }
        viewTapped?.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
    }
    
    func buyProduct() {
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
    }
    
    func updateCoinsLabel() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedCoins = numberFormatter.string(from: NSNumber(value:coins))
        currentCoins.text = formattedCoins
    }
    
    @IBOutlet weak var gifView: UIImageView!
    func addPurchasedCoins(amount: Int) {
        
        gifView.isHidden = false
        
        let gif = UIImage(gifName: "coin.gif")
        let gifManager = SwiftyGifManager(memoryLimit: 20)
        self.gifView.setGifImage(gif, manager: gifManager, loopCount: 1)
        
        coins += amount
        SharingManager.sharedInstance.lifetimeScore += amount
        
        if coins >= 100000 {
            slide7.image.image = #imageLiteral(resourceName: "trumpStore")
            slide7.titleLabel.text = "trumpoos"
        }
        updateCoinsLabel()
        
        if amount > 250 {
            hideAddCoinsModal()
        }
    }
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let myProduct = response.products
        for product in myProduct {
            list.append(product)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            
            switch trans.transactionState {
            case .purchased:
                let prodID = p.productIdentifier
                switch prodID {
                case "org.pooscaboose.onek":
                    addPurchasedCoins(amount: 1000)
                    
                case "org.pooscaboose.fivek":
                    addPurchasedCoins(amount: 5000)
                    
                case "org.pooscaboose.tenk":
                    addPurchasedCoins(amount: 10000)
                    
                case "org.pooscaboose.hundredk":
                    addPurchasedCoins(amount: 100000)
                    
                default:
                    print("Not found")
                }
            case .failed:
                queue.finishTransaction(trans)
                break
                
            default:
                break
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contacts = [CNContact]()
    var authStatus: CNAuthorizationStatus = .denied {
        didSet {
            DispatchQueue.main.sync {
                searchBar.isUserInteractionEnabled = authStatus == .authorized
            }
            
            if authStatus == .authorized { // all search
                contacts = fetchContacts("")
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    fileprivate let kCellID = "ContactsTableViewCell"
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        contacts = fetchContacts(searchText)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! ContactsTableViewCell
        
        let contact = contacts[indexPath.row]
        
        // get the full name
        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "NO NAME"
        cell.nameLabel?.text = fullName.lowercased()
        
        return cell
    }
    
    fileprivate func checkAuthorization() {
        // get current status
        let status = CNContactStore.authorizationStatus(for: .contacts)
        authStatus = status
        
        switch status {
        case .notDetermined: // case of first access
            CNContactStore().requestAccess(for: .contacts) { [unowned self] (granted, error) in
                if granted {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .denied
                }
            }
        case .restricted, .denied:
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                self.open(link: String(describing: url))
            })
            showAlert(
                title: "Permission Denied",
                message: "You can change your settings to allow access to contacts.",
                actions: [okAction, settingsAction])
        case .authorized:
            print("Authorized")
        }
    }
    // Opening URLs with iOS 10 & below
    func open(link: String) {
        if let url = URL(string: link) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(link): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(link): \(success)")
            }
        }
    }
    
    
    // get the contacts of matching names
    fileprivate func fetchContacts(_ searchName: String?) -> [CNContact] {
        let store = CNContactStore()
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor])
            if let name = searchName {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
            }
            else {
                request.predicate = nil
            }
            
            var contacts = [CNContact]()
            try store.enumerateContacts(with: request, usingBlock: { (contact, error) in
                contacts.append(contact)
            })
            
            return contacts
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = contacts[indexPath.row]
        selectedPhoneNumber = ""
        
        for phoneNumber:CNLabeledValue in contact.phoneNumbers {
            let number  = phoneNumber.value
            
            let tempNumString = "0123456789"
            
            for c in number.stringValue {
                if tempNumString.contains(c) {
                    selectedPhoneNumber.append(c)
                }
            }
            break
        }
        
        let messageComposer = MessageComposer()
        
        let textMessageRecipients = ["\(selectedPhoneNumber)"]
        if (messageComposer.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Yo hop on the Caboose, Poos! http://pooscaboose.com/download";
            messageVC.recipients = textMessageRecipients
            messageVC.messageComposeDelegate = self;
            
            self.present(messageVC, animated: false, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
            let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(errorAlert, animated: true){}
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func checkIfSharedPreviously() -> Bool {
        if SharingManager.sharedInstance.sharedContacts.contains(selectedPhoneNumber) {
            return false
        }
        else {
            SharingManager.sharedInstance.sharedContacts.append(selectedPhoneNumber)
            return true
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            controller.dismiss(animated: true, completion: nil)
            if checkIfSharedPreviously() == true {
            addPurchasedCoins(amount: 250)
            }
            darkenedView.isHidden = false
        default:
            break;
        }
    }
    
    fileprivate func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        for action in actions {
            alert.addAction(action)
        }
        
        DispatchQueue.main.async(execute: { [unowned self] () in
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: r.lowerBound)
        let end = self.index(start, offsetBy: r.upperBound - r.lowerBound)
        return String(self[Range(start ..< end)])
    }
}
extension StoreViewController: SwiftyGifDelegate {
    
    func gifDidLoop() {
        gifView.isHidden = true
    }
}
extension UIImage {
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
