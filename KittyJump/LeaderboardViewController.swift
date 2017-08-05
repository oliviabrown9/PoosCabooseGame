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
    var facebookId = ""
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        if user != nil {
            loginButton.isEnabled = false
            loginButton.isHidden = true
            fetchFriends()
            
            
        }
    }
    
    func addPlayer() {
        ref?.child("players").child(user!.uid).updateChildValues(["name": user!.displayName!, "facebookId": FBSDKAccessToken.current().userID])
    }
    
    func fetchFriends() {
        let params = ["fields": "id, name, email, picture"]
        FBSDKGraphRequest(graphPath: "me/friends", parameters: params).start { (connection, result , error) -> Void in
            
            if error != nil {
                print(error!)
            }
            else {
                print(result!)
                //Do further work with response
            }
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
                
            })
            
        }
        
        fetchFriends()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
