//
//  SplashViewController.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/27/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import Gifu

class SplashViewController: UIViewController {
    
    @IBOutlet var gifImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        gifImageView.animate(withGIFNamed: "sample", loopCount: 1)
        
        let hasItStopped = gifImageView.isAnimating
        
        if hasItStopped == false {
            performSegue(withIdentifier: "toStart", sender: self)
        }
        else {
            }
        }
    }
extension UIImageView: GIFAnimatable {
    
    private struct AssociatedKeys {
        static var AnimatorKey = "gifu.animator.key"
    }
    
    override open func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
    
    public var animator: Animator? {
        get {
            guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
                let animator = Animator(withDelegate: self)
                self.animator = animator
                return animator
            }
            
            return animator
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
