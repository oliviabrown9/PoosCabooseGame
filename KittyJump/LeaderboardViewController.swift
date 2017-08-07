//
//  LoginViewController.swift
//
//
//  Created by Olivia Brown on 7/31/17.
//
//

import UIKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore
import Firebase
import FirebaseDatabase
import SwiftyJSON

class LoginViewController: UIViewController {
    
    var ref: DatabaseReference?
    let user = Auth.auth().currentUser
    var facebookId = "";
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(FBSDKAccessToken.current() != nil){
        facebookId = FBSDKAccessToken.current().userID;
        print("FB USER ID IS %@",facebookId)
        }
        
        ref = Database.database().reference()
        if FBSDKAccessToken.current() != nil {
            loginButton.isEnabled = false
            loginButton.isHidden = true
            logoutButton.isHidden = false
            getFriendsScore()
        }else{
            logoutButton.isHidden = true
        }

    }
    
    
    func getScoreUser(fb_user: String) -> String{
        var score:String = "";
        self.ref?.child("players").child(fb_user).observeSingleEvent(of: .value, with: { (snapshot) in
            score = snapshot.childSnapshot(forPath: "highScore").value as! String
            print("score is %@",score );
            
        }) { (error) in
            print(error.localizedDescription)
        }
        return score;
    }
    
    func getFriendsScore(){
        
        let params = ["fields": "id, first_name, last_name, name, email, picture"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if error == nil {
                if let userData = result as? [String:Any] {
                    print("Friends list")
                    print(userData)
                    let friendObjects = userData["data"] as! [NSDictionary]
                    for friendObject in friendObjects {
                        let fbId = friendObject["id"] as! NSString;
                        let fbuName = friendObject["name"] as! NSString;
                        print("FBid \(fbId)");
                        print("fbuName \(fbuName)");
                        print("Score \(self.getScoreUser(fb_user: fbId as String))")
                        
                    }
                    print("\(friendObjects.count)")
                }
            } else {
                print("Error Getting Friends \(String(describing: error))");
            }
            
        })
        
        connection.start()
        
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                self.getFBUserData()
                
            })
            
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
//        getFBUserData()
    }
    
    func getFBUserData()
    {
        
        
        if((FBSDKAccessToken.current()) != nil ) {
            
            FBSDKGraphRequest(graphPath: "me",
                              
                              parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                                
                                completionHandler: { (connection, result, error) -> Void in
                                    print(result.debugDescription);
                                    self.ref?.child("players").child(FBSDKAccessToken.current().userID).child("profile").updateChildValues(result as! [AnyHashable : Any]) //
                                    _ = self.navigationController?.popViewController(animated: true)
                              })
        }
    }
    

}
