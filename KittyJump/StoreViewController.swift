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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCoins.text = "\(SharingManager.sharedInstance.lifetimeScore)"
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
