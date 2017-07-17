//
//  StoreViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 7/10/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

var using: Int = 0

class StoreViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var currentCoins: UILabel!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var darkenedView: UIView!
    @IBOutlet weak var modalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var peek: UIImageView!
    @IBAction func backButtonPressed(_ sender: Any) {
        print("pressed")
        performSegue(withIdentifier: "unwindToGameOver", sender: self)
    }
    
    // Slides
    let slide0 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide1 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide2 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide3 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide4 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
    let slide5 = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide

    @IBOutlet weak var scrollView: UIScrollView!
    var confirm: Bool = false
//    var coins = SharingManager.sharedInstance.lifetimeScore
    var coins = 1000000
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let slides: [Slide] = createSlides()
        setupScrollView(slides: slides)
        
        scrollView.delegate = self
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        
        currentCoins.text = "\(coins)"
        }
    
    func setupInCloset(slide: Slide) {
        slide.buyButton.isHidden = true
        slide.coinImage.isHidden = true
        slide.costLabel.isHidden = true
        slide.coinLabel.isHidden = true
        slide.useButton.isHidden = false
        slide.useButton.layer.cornerRadius = 20
        slide.useButton.layer.borderWidth = 3
        slide.useButton.layer.borderColor = UIColor.white.cgColor
        slide.useButton.addTarget(self, action: #selector(updateUsing), for: .touchUpInside)
    }
    
    func setupInStore(slide: Slide) {
        slide.buyButton.layer.cornerRadius = 20
        slide.buyButton.layer.borderWidth = 3
        slide.buyButton.layer.borderColor = UIColor.white.cgColor
        slide.buyButton.addTarget(self, action: #selector(purchaseItem), for: .touchUpInside)
    }
    
    func createSlides() -> [Slide] {
        
        let slideArray = [slide0, slide1, slide2, slide3, slide4, slide5]
        
        var x = 0
        for i in slideArray {
            if SharingManager.sharedInstance.itemStates[x] == "inCloset" {
                setupInCloset(slide: i)
            }
            else {
                setupInStore(slide: i)
            }
            x += 1
        }
        
        slide0.image.image = #imageLiteral(resourceName: "poos")
        slide0.titleLabel.text = "og poos"
        
        slide1.image.image = #imageLiteral(resourceName: "trotterpoos")
        slide1.titleLabel.text = "trotter poos"
        slide1.costLabel.text = "1,000"
        
        slide2.image.image = #imageLiteral(resourceName: "properpoos")
        slide2.titleLabel.text = "proper poos"
        slide2.costLabel.text = "2,000"
        
        slide3.image.image = #imageLiteral(resourceName: "poosrate")
        slide3.titleLabel.text = "poosrate"
        slide3.costLabel.text = "5,000"
        
        slide4.image.image = #imageLiteral(resourceName: "quapoos")
        slide4.titleLabel.text = "quapoos"
        slide4.costLabel.text = "10,000"
        
        slide5.image.image = #imageLiteral(resourceName: "trumpoos")
        slide5.titleLabel.text = "trumpoos"
        slide5.costLabel.text = "100,000"
        
        return [slide0, slide1, slide2, slide3, slide4, slide5]
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
        setupInCloset(slide: currentSlide)
    }
    
    func updateUsing() {
        
        if pageIndex == 0 {
            SharingManager.sharedInstance.using = 0
            SharingManager.sharedInstance.catImageString = "poos"
        }
        else if pageIndex == 1 {
            SharingManager.sharedInstance.using = 1
            SharingManager.sharedInstance.catImageString = "trotterpoos"
        }
        else if pageIndex == 2 {
            SharingManager.sharedInstance.using = 2
            SharingManager.sharedInstance.catImageString = "properpoos"
        }
        else if pageIndex == 3 {
            SharingManager.sharedInstance.using = 3
            SharingManager.sharedInstance.catImageString = "poosrate"
        }
        else if pageIndex == 4 {
            SharingManager.sharedInstance.using = 4
            SharingManager.sharedInstance.catImageString = "quapoos"
        }
        else if pageIndex == 5 {
            SharingManager.sharedInstance.using = 5
            SharingManager.sharedInstance.catImageString = "trumpoos"
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
                self.peek.isHidden = true
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
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
