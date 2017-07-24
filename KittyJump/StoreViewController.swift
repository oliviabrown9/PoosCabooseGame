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

var using: Int = 0
var selectedPhoneNumber: String = ""

class StoreViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver ,MFMessageComposeViewControllerDelegate {
    
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
    
    // Slides
    let slide0 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide1 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide2 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide3 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide4 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide5 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide6 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add coin button click
        
        let addCoinBtnClick = UITapGestureRecognizer(target: self, action: #selector(showAddCoinsView))
        coinImage.isUserInteractionEnabled = true
        coinImage.addGestureRecognizer(addCoinBtnClick)
        
        let slides: [Slide] = createSlides()
        setupScrollView(slides: slides)
        
        checkAuthorization()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        
        currentCoins.text = "\(coins)"
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.delegate = self
        self.view.addGestureRecognizer(swipeRight)
        
        if (SKPaymentQueue.canMakePayments()) {
            let productID: NSSet = NSSet(objects: "com.pooscaboose.onek", "com.pooscaboose.fivek", "com.pooscaboose.tenk", "com.pooscaboose.hundredk")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            
            request.delegate = self
            request.start()
        }
        else {
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if pageIndex == 0 {
            performSegue(withIdentifier: "unwindToGameOver", sender: self)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func buttonInUse(button: UIButton) {
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor(red:0.21, green:0.81, blue:0.85, alpha:1.0), for: .normal)
        button.setTitle("in use", for: .normal)
    }
    
    func buttonNotInUse(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("use", for: .normal)
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
    
    func createSlides() -> [Slide] {
        
        let slideArray = [slide0, slide1, slide2, slide3, slide4, slide5, slide6]
        
        var x = 0
        for i in slideArray {
            if SharingManager.sharedInstance.itemStates[x] == "inCloset" {
                setupInCloset(slide: i, x: x)
            }
            else {
                setupInStore(slide: i)
            }
            x += 1
        }
        
        slide0.image.image = #imageLiteral(resourceName: "ogStore")
        slide0.titleLabel.text = "og poos"
        slide0.imageHeight.constant = 216
        
        slide1.image.image = #imageLiteral(resourceName: "trotterStore")
        slide1.titleLabel.text = "poos trotter"
        slide1.costLabel.text = "1,000"
        slide1.imageHeight.constant = 245
        
        slide2.image.image = #imageLiteral(resourceName: "properStore")
        slide2.titleLabel.text = "proper poos"
        slide2.costLabel.text = "2,000"
        slide2.imageHeight.constant = 230
        
        slide3.image.image = #imageLiteral(resourceName: "rateStore")
        slide3.titleLabel.text = "poosrate"
        slide3.costLabel.text = "5,000"
        slide3.imageHeight.constant = 217
        
        slide4.image.image = #imageLiteral(resourceName: "quaStore")
        slide4.titleLabel.text = "quapoos"
        slide4.costLabel.text = "10,000"
        slide4.imageHeight.constant = 217
        
        slide5.image.image = #imageLiteral(resourceName: "pousStore")
        slide5.titleLabel.text = "le pous"
        slide5.costLabel.text = "25,000"
        slide5.imageHeight.constant = 208
        
        if coins >= 100000 {
            slide6.image.image = #imageLiteral(resourceName: "trumpStore")
            slide6.titleLabel.text = "trumpoos"
            slide6.imageHeight.constant = 216
        }
        else {
            slide6.image.image = #imageLiteral(resourceName: "mysteryStore")
            slide6.titleLabel.text = "?????"
            slide6.imageHeight.constant = 207
        }
        slide6.costLabel.text = "100,000"
        
        return [slide0, slide1, slide2, slide3, slide4, slide5, slide6]
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
        
        var currentSlide: Slide = slide1
        
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
        setupInCloset(slide: currentSlide, x: pageIndex)
    }
    
    func updateUseButton() {
        let allSlides = [slide0, slide1, slide2, slide3, slide4, slide5, slide6]
        
        var x = 0
        for i in allSlides {
            if SharingManager.sharedInstance.using == x {
                buttonInUse(button: i.useButton)
            }
            else {
                if SharingManager.sharedInstance.itemStates[x] == "inCloset" {
                    buttonNotInUse(button: i.useButton)
                }
                else {
                    buttonInUse(button: i.useButton)
                }
            }
            x += 1
        }
    }
    
    func updateUsing() {
        
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
            SharingManager.sharedInstance.catImageString = "properpoos"
            updateUseButton()
        }
        else if pageIndex == 3 {
            SharingManager.sharedInstance.using = 3
            SharingManager.sharedInstance.catImageString = "poosrate"
            updateUseButton()
        }
        else if pageIndex == 4 {
            SharingManager.sharedInstance.using = 4
            SharingManager.sharedInstance.catImageString = "quapoos"
            updateUseButton()
        }
        else if pageIndex == 5 {
            SharingManager.sharedInstance.using = 5
            SharingManager.sharedInstance.catImageString = "pous"
            updateUseButton()
        }
        else if pageIndex == 6 {
            SharingManager.sharedInstance.using = 6
            SharingManager.sharedInstance.catImageString = "trumpoos"
            updateUseButton()
        }
    }
    
    // Try to buy something
    func purchaseItem() {
        let failureGenerator = UINotificationFeedbackGenerator()
        failureGenerator.prepare()
        
        if pageIndex == 0 {
            cost = 0
        }
        else if pageIndex == 1 {
            cost = 1000
        }
        else if pageIndex == 2 {
            cost = 2000
        }
        else if pageIndex == 3 {
            cost = 5000
        }
        else if pageIndex == 4 {
            cost = 10000
        }
        else if pageIndex == 5 {
            cost = 25000
        }
        else if pageIndex == 6 {
            cost = 100000
        }
        
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
            SharingManager.sharedInstance.itemStates[pageIndex] = "inCloset"
            itemAlreadyPurchased()
        }
        else if confirm == true && cost >= coins {
            showAddCoinsView();
        }
    }
    
    func showAddCoinsView(){
        view.layoutIfNeeded()
        
        darkenedView.isHidden = false
        modalView.isHidden = true
        addCoinsView.layer.cornerRadius = 28
        addCoinsLabel.text = "Pick your poos coin \n package"
        peek.isHidden = false
        addCoinsView.isHidden = false
        addCoinsGestures()
    }
    
    func inviteFriends() {
        inviteFriendsView.layer.cornerRadius = 28
        inviteFriendsView.isHidden = false
//        addCoinsView.isHidden = true
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
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            if finished {
                self.addCoinsView.isHidden = true
                self.shareTopConstraint.constant -= self.view.bounds.height
                self.peek.isHidden = true
                self.inviteFriendsView.isHidden = true
            }
        })
    }
    
    @IBAction func cancelShare(_ sender: Any) {
        hideShareModal()
    }
    
    @IBAction func cancelAddCoins(_ sender: Any) {
        hideAddCoinsModal() // no prob
    }
    
    func buyCoins(_ recognizer: UITapGestureRecognizer) {
        
        let viewTapped = recognizer.view
        viewTapped?.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        
        if viewTapped == secondAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "com.pooscaboose.onek" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == thirdAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "com.pooscaboose.fivek" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == fourthAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "com.pooscaboose.tenk" {
                    p = product
                    buyProduct()
                }
            }
        }
        else if viewTapped == fifthAddCoins {
            for product in list {
                let prodID = product.productIdentifier
                if prodID == "com.pooscaboose.hundredk" {
                    p = product
                    buyProduct()
                }
            }
        }
    }
    
    func buyProduct() {
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
        
    }
    
    func addPurchasedCoins(amount: Int) {
        coins += amount
        SharingManager.sharedInstance.lifetimeScore += amount
        currentCoins.text = "\(coins)"
        hideAddCoinsModal()
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
                case "com.pooscaboose.onek":
                    addPurchasedCoins(amount: 1000)
                    
                case "com.pooscaboose.fivek":
                    addPurchasedCoins(amount: 5000)
                    
                case "com.pooscaboose.tenk":
                    addPurchasedCoins(amount: 10000)
                    
                case "com.pooscaboose.hundredk":
                    addPurchasedCoins(amount: 100000)
                    
                default:
                    print("IAP not found")
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
    
    // CONTACTS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var contacts = [CNContact]()
    var authStatus: CNAuthorizationStatus = .denied {
        didSet {
            searchBar.isUserInteractionEnabled = authStatus == .authorized
            
            if authStatus == .authorized { // all search
                contacts = fetchContacts("")
                tableView.reloadData()
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
        
        cell.viewController = self
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
                    NSLog("Permission allowed")
                    self.authStatus = .authorized
                } else {
                    NSLog("Permission denied")
                    self.authStatus = .denied
                }
            }
        case .restricted, .denied:
            NSLog("Unauthorized")
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                self.open(link: String(describing: url))
            })
            showAlert(
                title: "Permission Denied",
                message: "You have not permission to access contacts. Please allow the access the Settings screen.",
                actions: [okAction, settingsAction])
        case .authorized:
            NSLog("Authorized")
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
    
    
    // fetch the contact of matching names
    fileprivate func fetchContacts(_ name: String) -> [CNContact] {
        let store = CNContactStore()
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor])
            if name.isEmpty { // all search
                request.predicate = nil
            } else {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
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
            
            for c in number.stringValue.characters {
                if tempNumString.characters.contains(c) {
                    selectedPhoneNumber.append(c)
                }
            }
            break
        }
        
        let messageComposer = MessageComposer()
        
        let textMessageRecipients = ["\(selectedPhoneNumber)"]
        if (messageComposer.canSendText()) {
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Download this app.";
            messageVC.recipients = textMessageRecipients
            messageVC.messageComposeDelegate = self;
            
            self.present(messageVC, animated: false, completion: nil)
            
        } else {
            let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(errorAlert, animated: true){}
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            controller.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            addPurchasedCoins(amount: 250)
            controller.dismiss(animated: true, completion: nil)
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
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}
