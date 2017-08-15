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

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var today: Bool = true
    
    @IBAction func dayButtonPressed(_ sender: Any) {
        if today == true {
            today = false
            dayButton.setTitle("all time", for: .normal)
            friendArray.removeAll()
            getFriendsScore()
        }
        else {
            today = true
            dayButton.setTitle("today", for: .normal)
            friendArray.removeAll()
            getFriendsScore()
        }
    }
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference?
    let user = Auth.auth().currentUser
    var facebookId = "";
    var todayDict = [(String, String)]()
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginArrow: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
//        getWorldHighScores()
        
        dayButton.layer.borderWidth = 2
        dayButton.layer.borderColor = UIColor.white.cgColor
        dayButton.layer.cornerRadius = 17
        if(FBSDKAccessToken.current() != nil){
            facebookId = FBSDKAccessToken.current().userID;
        }
        else {
            loginButton.isHidden = false
            loginArrow.isHidden = true
        }
        
        if FBSDKAccessToken.current() != nil {
            loginButton.isHidden = true
            loginArrow.isHidden = true
            logoutButton.isHidden = false
            getFriendsScore()
        }else{
            logoutButton.isHidden = true
        }
    }
    
    var friendArray: [Friend] = []
    
    func makeFriends(fb_user: String) {
        var name: String = ""
        var score: String = "";
        var todaysHighScore: String = ""
        var imageString: String = ""
        
        if today == false {
            self.ref?.child("players").child(fb_user).observeSingleEvent(of: .value, with: { (snapshot) in
                score = String(describing: snapshot.childSnapshot(forPath: "highScore").value!)
                let foundFriend = Friend(name: name, highScore: score, todayScore: todaysHighScore, imageURL: imageString)
                self.friendArray.append(foundFriend)
                self.friendArray.sort { Int($0.highScore)! > Int($1.highScore)! }
                self.tableView.reloadData()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        else {
            self.ref?.child("players").child(fb_user).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
                score = String(describing: snapshot.childSnapshot(forPath: "score").value!)
                
            }) { (error) in
                print(error.localizedDescription)
            }

        }
        
        self.ref?.child("players").child(fb_user).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            name = String(describing: snapshot.childSnapshot(forPath: "name").value!)
            if self.today == true {
                let foundFriend = Friend(name: name, highScore: score, todayScore: todaysHighScore, imageURL: imageString)
                self.friendArray.append(foundFriend)
                self.friendArray.sort { Int($0.highScore)! > Int($1.highScore)! }
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.ref?.child("players").child(fb_user).child("profile").child("picture").child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            imageString = String(describing: snapshot.childSnapshot(forPath: "url").value!)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.ref?.child("players").child(fb_user).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
            todaysHighScore = String(describing: snapshot.childSnapshot(forPath: "score").value!)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFriendsScore(){
        
        makeFriends(fb_user: facebookId as String)
        
        let params = ["fields": "id, first_name, last_name, name, email, picture"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if error == nil {
                if let userData = result as? [String:Any] {
                    let friendObjects = userData["data"] as! [NSDictionary]
                    for friendObject in friendObjects {
                        let fbId = friendObject["id"] as! NSString;
                        self.makeFriends(fb_user: fbId as String)
                    }
                }
            } else {
                print("Error Getting Friends \(String(describing: error))");
            }
        })
        connection.start()
    }
    
//    func getWorldHighScores() {
//        let query = ref?.child("players").queryOrdered(byChild: "highScore").queryLimited(toFirst: 10)
//        query?.observe(.value, with: { (snapshot) in
//            if let results = snapshot.value as? NSDictionary {
//                print("key: \(snapshot.key), value: \(snapshot.value)")
//            }
//        })
//    }
//    
    @IBAction func backClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            logoutButton.isHidden = true
            loginButton.isHidden = false
            loginArrow.isHidden = false
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
            self.loginButton.isHidden = true
            self.loginArrow.isHidden = true
            self.logoutButton.isHidden = false
            
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
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardTableViewCell
        cell.selectionStyle = .none
        cell.nameLabel.text = friendArray[indexPath.row].name
        cell.scoreLabel.text = friendArray[indexPath.row].highScore
        cell.profileImage.downloadedFrom(link: friendArray[indexPath.row].imageURL)
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2
        cell.profileImage.layer.borderWidth = 2
        cell.profileImage.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getFBUserData()
    {
        if((FBSDKAccessToken.current()) != nil ) {
            
            FBSDKGraphRequest(graphPath: "me",
                              
                              parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email , gender"]).start(
                                
                                completionHandler: { (connection, result, error) -> Void in
                                    print(result.debugDescription);
                                    self.ref?.child("players").child(FBSDKAccessToken.current().userID).child("profile").updateChildValues(result as! [AnyHashable : Any])
                              })
        }
    }
}


extension UIImageView {
    func downloadedFromURL(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFromURL(url: url, contentMode: mode)
}
}
