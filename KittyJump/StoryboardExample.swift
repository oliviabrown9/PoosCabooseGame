//
//  StoryboardExampleViewController.swift
//  SwiftyOnboardExample
//
//  Created by Jay on 3/27/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit
import SwiftyOnboard

class StoryboardExampleViewController: UIViewController {

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

extension StoryboardExampleViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 4
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as? CustomPage
        view?.image.image = UIImage(named: "")
        if index == 0 {
            //On the first page, change the text in the labels to say the following:
            view?.titleLabel.text = "test"
            view?.subTitleLabel.text = "test"
        } else if index == 1 {
            //On the second page, change the text in the labels to say the following:
            view?.titleLabel.text = "test2"
            view?.subTitleLabel.text = "test2"
        } else if index == 2 {
            //On the third page, change the text in the labels to say the following:
            view?.titleLabel.text = "test3"
            view?.subTitleLabel.text = "test3"
        }
        else {
            //On the third page, change the text in the labels to say the following:
            view?.titleLabel.text = "test4"
            view?.subTitleLabel.text = "test4"
        }
        return view
    }
    
    func moveOn() {
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
            overlay.buttonContinue.setTitle("Continue", for: .normal)
            overlay.skip.setTitle("Skip", for: .normal)
            overlay.skip.isHidden = false
        } else {
            overlay.buttonContinue.setTitle("Get Started!", for: .normal)
            overlay.buttonContinue.addTarget(self, action: #selector(moveOn), for: .touchUpInside)
            overlay.skip.isHidden = true
        }
    }
}
