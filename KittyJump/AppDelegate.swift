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
import FBSDKLoginKit
import FacebookLogin
import FacebookCore


var myItemStates: [String] = []

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstitialDelegate {
    
    var window: UIWindow?
    var ref: DatabaseReference?
    let date = Date()
    var facebookId = "";
    var gViewController: UIViewController?
    var mInterstitial: GADInterstitial!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1224845211182149~2532664151")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController? = nil
            initialViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController")
        self.window?.rootViewController = initialViewController
        self.gViewController = initialViewController;
        self.window?.makeKeyAndVisible()
        if(FBSDKAccessToken.current() != nil){
            facebookId = FBSDKAccessToken.current().userID;
            syncFireBaseDb()
            getFBUserData()
        }
        
        self.window?.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundGradient")!)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
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
    
    
    
    func syncFireBaseDb(){
        
        self.ref = Database.database().reference()
        _ = Auth.auth().currentUser
        if(facebookId != ""){
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let dateString = formatter.string(from: self.date)

            var dbDateString:String = "";
            self.ref?.child("players").child(facebookId).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
                //read the user data from the snapshot and do whatever with it
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        let key = child.key ;
                        if(key.contains("date")){
                            dbDateString = child.value as! String;
                        }
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let dbDate = formatter.date(from: dbDateString) // Format date string
                    let localDate = formatter.date(from: dateString)
                    if(dbDate == nil){
                        self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["date": dateString])
                        self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["score": 0]) // Set to 0
                    }
                    else
                        if(dbDate! < localDate!) {
                            self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["date": dateString])
                            self.ref?.child("players").child(self.facebookId).child("TodayshighScore").updateChildValues(["score": 0]) //Reset to 0
                        }
                    
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
            self.ref?.child("players").child(facebookId).child("poosesOwned").observeSingleEvent(of: .value, with: { (snapshot) in
                // Read user data from the snapshot
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        let val = child.value as! String
                        itemStates.append(val);
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func getFBUserData()
    {
        if((FBSDKAccessToken.current()) != nil ) {
            
            FBSDKGraphRequest(graphPath: "me",
                              
                              parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                                
                                completionHandler: { (connection, result, error) -> Void in
                                    self.ref?.child("players").child(self.facebookId).child("profile").updateChildValues(result as! [AnyHashable : Any])
                              })
        }
    }
}
extension String {
    func makeFirebaseString()->String{
        let arrCharacterToReplace = [".","#","$","[","]"]
        var finalString = self
        
        for character in arrCharacterToReplace{
            finalString = finalString.replacingOccurrences(of: character, with: " ")
        }
        return finalString
    }
}
