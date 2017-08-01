//
//  LoginViewController.swift
//  
//
//  Created by Olivia Brown on 7/31/17.
//
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.center = view.center
        loginButton.layoutSubviews()
        
        view.addSubview(loginButton)
    }
}
