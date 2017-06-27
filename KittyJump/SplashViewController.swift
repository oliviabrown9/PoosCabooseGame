//
//  SplashViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/27/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var gifImageView: UIImageView!
    var animateComplete: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gif = UIImage.gifImageWithName(name: "sample")
        let imageView = UIImageView(image: gif)
        imageView.frame = CGRect(x: 20.0, y: 50.0, width: self.view.frame.size.width - 40, height: 150.0)
        view.addSubview(imageView)
    }


//        if gifImageView.isAnimatingGIF == false {
//            DispatchQueue.main.async(execute: {
//                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController")
//                self.show(vc, sender: self)
//            })
//        }
}
