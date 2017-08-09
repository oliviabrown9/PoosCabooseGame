//
//  AdsViewController.swift
//  KittyJump
//
//  Created by Timothy on 09/08/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsViewController: UIViewController, GADInterstitialDelegate{
    
    var viewController: UIViewController?
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed1212122")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1224845211182149/4021005644")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
    //
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        //        if showFirst == true && playCount % 3 == 0 && removedAds == false {
        interstitial.present(fromRootViewController: self)
        //            showFirst = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
