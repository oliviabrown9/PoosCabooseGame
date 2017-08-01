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

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchFriends() {
    let params = ["fields" : "email, name"]
    let graphRequest = GraphRequest(graphPath: "me", parameters: params)
    graphRequest.start {
    (urlResponse, requestResult) in
    
    switch requestResult {
    case .failed(let error):
    print("error in graph request:", error)
    break
    case .success(let graphResponse):
    if let responseDictionary = graphResponse.dictionaryValue {
    print(responseDictionary)
    
    print(responseDictionary["name"])
    print(responseDictionary["email"])
    }
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
    }}
