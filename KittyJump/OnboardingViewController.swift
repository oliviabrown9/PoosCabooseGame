//
//  StoryboardExampleViewController.swift
//  SwiftyOnboardExample
//
//  Created by Olivia Brown on 7/17/17.
//  
//  SwiftyOnboarding Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//  All other code Copyright © 2017 Olivia Brown. All rights reserved.

import UIKit
import SwiftyOnboard

class OnboardingViewController: UIViewController {

    @IBOutlet weak var swiftyOnboard: SwiftyOnboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftyOnboard.style = .light
        swiftyOnboard.delegate = self
        swiftyOnboard.dataSource = self
    }
    
    func handleSkip() {
        swiftyOnboard?.goToPage(index: 3, animated: true)
    }
    
    func handleContinue(sender: UIButton) {
        let index = sender.tag
        swiftyOnboard?.goToPage(index: index + 1, animated: true)
    }
}

extension OnboardingViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 4
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as? CustomPage
        view?.image.image = UIImage(named: "")
        if index == 0 {
            //On the first page, change the text in the labels to say the following:
            view?.titleLabel.text = "Tap when your Poos \n lines up with the next \n caboose."
            view?.image.image = #imageLiteral(resourceName: "onOne")
        } else if index == 1 {
            //On the second page, change the text in the labels to say the following:
            view?.titleLabel.text = "Each successful jump \n counts as 1 point."
            view?.image.image = #imageLiteral(resourceName: "onTwo")
        } else if index == 2 {
            //On the third page, change the text in the labels to say the following:
            view?.titleLabel.text = "Points become poos \n coin after each game."
            view?.image.image = #imageLiteral(resourceName: "onThree")
        }
        else {
            //On the third page, change the text in the labels to say the following:
            view?.titleLabel.text = "Poos coins unlocks \n swag."
            view?.image.image = #imageLiteral(resourceName: "onFour")
        }
        return view
    }
    
    func moveOn() {
        SharingManager.sharedInstance.onboardingFinished = true
        performSegue(withIdentifier: "toGame", sender: self)
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
        overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay?.buttonContinue.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
        let currentPage = round(position)
        overlay.pageControl.currentPage = Int(currentPage)
        overlay.buttonContinue.tag = Int(position)
        if currentPage == 0.0 || currentPage == 1.0 || currentPage == 2.0 {
            overlay.buttonContinue.isHidden = true
            overlay.skip.isHidden = false
        } else {
            overlay.buttonContinue.addTarget(self, action: #selector(moveOn), for: .touchUpInside)
            overlay.buttonContinue.isHidden = false
            overlay.skip.isHidden = true
        }
    }
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
