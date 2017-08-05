//
//  AppDelegate.swift
//  KittyJump
//
//  Created by Olivia Brown on 6/9/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseDatabase
import FBSDKCoreKit

var myItemStates: [String] = []

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var ref: DatabaseReference?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1224845211182149~2532664151")
        
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
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        
        ref?.child("players").child(user!.uid).child("poosesOwned").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let val = child.value as! String
                    itemStates.append(val)
                }
            } else {
                print("no results")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
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
