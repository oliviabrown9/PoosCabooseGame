//
//  AppDelegate.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/9/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
// import Flurry_iOS_SDK
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Flurry.startSession("CF7YYJD5WPHPFJZ2HJSZ");
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var initialViewController: UIViewController? = nil
        
        if SharingManager.sharedInstance.onboardingFinished == false {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController")
        }
        else {
            initialViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController")
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8959953054263820~4674777616")
    
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
