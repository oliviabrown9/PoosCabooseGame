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

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var today: Bool = true
    
    @IBOutlet weak var friendTab: UILabel!
    @IBOutlet weak var worldTab: UILabel!
    @IBOutlet weak var friendHigh: UIView!
    @IBOutlet weak var worldHigh: UIView!
    let date = Date()
    let todayLocalized = NSLocalizedString("today", comment: "today")
    let alltimeLocalized = NSLocalizedString("all time", comment: "all time")
    
    
    @IBAction func dayButtonPressed(_ sender: Any) {
        if today == true {
            today = false
            dayButton.setTitle("\(alltimeLocalized)", for: .normal)
            if(friendHigh.isHidden) {
                
                self.worldArray.sort { Int($0.highScore) > Int($1.highScore) }
                tableView.reloadData()
            }else{
                
                friendArray.removeAll()
                getFriendsScore()
                tableView.reloadData()
            }
        }
        else {
            today = true
            
            dayButton.setTitle("\(todayLocalized)", for: .normal)
            if(friendHigh.isHidden) {
                
                self.worldArray.sort { Int($0.todayScore) > Int($1.todayScore) }
                tableView.reloadData()
            }else{
                
                friendArray.removeAll()
                getFriendsScore()
                tableView.reloadData()
            }
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
        worldTab.isUserInteractionEnabled = true
        let friend = UITapGestureRecognizer(target: self, action: #selector(self.frindTabClicked))
        friendTab.isUserInteractionEnabled = true
        friendTab.addGestureRecognizer(friend)
        
        worldHigh.layer.cornerRadius = 2
        friendHigh.layer.cornerRadius = 2
        worldTab.isUserInteractionEnabled = true
        
        let world = UITapGestureRecognizer(target: self, action: #selector(self.worldTabClicked))
        worldTab.isUserInteractionEnabled = true
        worldTab.addGestureRecognizer(world)
        
        dayButton.layer.borderWidth = 2
        dayButton.layer.borderColor = UIColor.white.cgColor
        dayButton.layer.cornerRadius = 17
        if(FBSDKAccessToken.current() != nil){
            facebookId = FBSDKAccessToken.current().userID;
        }
        else {
            loginButton.isHidden = false
            loginArrow.isHidden = false
        }
        
        if FBSDKAccessToken.current() != nil {
            loginButton.isHidden = true
            loginArrow.isHidden = true
            logoutButton.isHidden = false
            if(FBSDKAccessToken.current() != nil){
                facebookId = FBSDKAccessToken.current().userID;
            }
            getFriendsScore()
            getWorldScore()
        }else{
            logoutButton.isHidden = true
        }
    }
    
    func frindTabClicked(sender:UITapGestureRecognizer) {
        friendHigh.isHidden = false
        friendTab.font = UIFont(name: "Avenir-Black", size: 18.0)
        worldHigh.isHidden = true
        worldTab.font = UIFont(name: "Avenir-Medium", size: 18.0)
        tableView.reloadData()
        
        if today == true {
            dayButton.setTitle("\(todayLocalized)", for: .normal)
        }
        else {
            dayButton.setTitle("\(alltimeLocalized)", for: .normal)
        }
    }
    
    var friendArray: [Friend] = []
    var worldArray: [World] = []
    
    
    func worldTabClicked(sender:UITapGestureRecognizer) {
        friendHigh.isHidden = true
        friendTab.font = UIFont(name: "Avenir-Medium", size: 18.0)
        worldHigh.isHidden = false
        worldTab.font = UIFont(name: "Avenir-Black", size: 18.0)
        tableView.reloadData()
        
        if today == true {
            dayButton.setTitle("\(todayLocalized)", for: .normal)
            self.worldArray.sort { Int($0.todayScore) > Int($1.todayScore) }
        }
        else {
            dayButton.setTitle("\(alltimeLocalized)", for: .normal)
            self.worldArray.sort { Int($0.highScore) > Int($1.highScore) }
        }
        tableView.reloadData()
    }
    
    func getWorldScore(){
        self.ref = Database.database().reference()
        self.ref?.child("players").queryOrdered(byChild: facebookId).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    
                    let snapDict = snapshot.value as? [String:AnyObject]
                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                        let json = snapDict?[snap.key]
                        let highScore = json?["highScore"] as? Int ?? 0
                        let profile = json?["profile"] as! NSDictionary;
                        let TodayshighScore = json?["TodayshighScore"] as! NSDictionary;
                        var todayhigh = TodayshighScore["score"] as? Int ?? 0
                        let scoreDate = TodayshighScore["date"] as! String
                        let name = profile["name"] as! String
                        let imageString = ((profile["picture"] as! NSDictionary)["data"]  as! NSDictionary)["url"] as! String
                        
                        if self.checkIfToday(scoreDate: scoreDate) == false {
                            todayhigh = 0
                        }
                        if name == "<null>" {
                            self.personExist = false
                        }
                        if self.personExist == true {
                        let foundFriend = World(name: name, highScore: highScore, todayScore: todayhigh, imageURL: imageString)
                        self.worldArray.append(foundFriend)
                        
                        if self.today == true {
                            self.worldArray.sort { Int($0.todayScore) > Int($1.todayScore) }
                        }
                        else {
                            self.worldArray.sort { Int($0.highScore) > Int($1.highScore) }
                        }
                        self.tableView.reloadData()
                        }
                        self.personExist = true
                    }
                }
            })
    }
    
    func checkIfToday(scoreDate: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let todayDate = formatter.string(from: self.date)
        
        if scoreDate != todayDate {
            return false
        }
        else {
            return true
        }
    }
    
    var personExist: Bool = true
    
    func makeFriends(fb_user: String) {
        var name: String = ""
        var score: String = "";
        var todaysHighScore: String = ""
        var imageString: String = ""
        var scoreDate: String = ""
        
        if today == false {
            self.ref?.child("players").child(fb_user).observeSingleEvent(of: .value, with: { (snapshot) in
                score = String(describing: snapshot.childSnapshot(forPath: "highScore").value!)
                if self.checkIfToday(scoreDate: scoreDate) == false {
                    todaysHighScore = "0"
                }
                if score == "<null>" {
                    score = "0"
                }
                if todaysHighScore == "<null>" {
                    todaysHighScore = "0"
                }
                if name == "<null>" {
                    self.personExist = false
                }
                if self.personExist == true {
                let foundFriend = Friend(name: name, highScore: score, todayScore: todaysHighScore, imageURL: imageString)
                self.friendArray.append(foundFriend)
                self.friendArray.sort { Int($0.highScore)! > Int($1.highScore)! }
                self.tableView.reloadData()
                }
                self.personExist = true
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        else {
            self.ref?.child("players").child(fb_user).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
                score = String(describing: snapshot.childSnapshot(forPath: "score").value!)
                scoreDate = String(describing: snapshot.childSnapshot(forPath: "date").value!)
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        self.ref?.child("players").child(fb_user).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
            name = String(describing: snapshot.childSnapshot(forPath: "name").value!)
            if self.today == true {
                if name == "<null>" {
                    self.personExist = false
                }
                if self.checkIfToday(scoreDate: scoreDate) == false {
                    todaysHighScore = "0"
                }
                if score == "<null>" {
                    score = "0"
                }
                if todaysHighScore == "<null>" {
                    todaysHighScore = "0"
                }
                
                if self.personExist == true {
                let foundFriend = Friend(name: name, highScore: score, todayScore: todaysHighScore, imageURL: imageString)
                self.friendArray.append(foundFriend)
                self.friendArray.sort { Int($0.todayScore)! > Int($1.todayScore)! }
                self.tableView.reloadData()
                }
                self.personExist = true
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToGameOver))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        self.ref?.child("players").child(fb_user).child("profile").child("picture").child("data").observeSingleEvent(of: .value, with: { (snapshot) in
            imageString = String(describing: snapshot.childSnapshot(forPath: "url").value!)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.ref?.child("players").child(fb_user).child("TodayshighScore").observeSingleEvent(of: .value, with: { (snapshot) in
            scoreDate = String(describing: snapshot.childSnapshot(forPath: "date").value!)
            todaysHighScore = String(describing: snapshot.childSnapshot(forPath: "score").value!)
        
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func swipeToGameOver() {
        performSegue(withIdentifier: "leaderboardToGameOver", sender: self)
    }
    
    func getFriendsScore(){
        if(facebookId != ""){

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
                print("\(String(describing: error))");
            }
        })
        connection.start()
        }
    }
    
    
    @IBAction func backClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "leaderboardToGameOver", sender: self)
    }
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            logoutButton.isHidden = true
            loginButton.isHidden = false
            loginArrow.isHidden = false
            tableView.isHidden = true
        } catch let signOutError as NSError {
            print (signOutError)
        }
    }
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            self.loginButton.isHidden = true
            self.loginArrow.isHidden = true
            self.logoutButton.isHidden = false
            self.tableView.isHidden = false
            
            guard let accessToken = FBSDKAccessToken.current() else {
                return
            }
            
            if(FBSDKAccessToken.current() != nil){
                self.facebookId = FBSDKAccessToken.current().userID;
            }
            self.getFBUserData()
            self.getFriendsScore()
            self.getWorldScore()
            
            self.tableView.reloadData()
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("\(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(friendHigh.isHidden){
            return worldArray.count
        }else{
            return friendArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LeaderboardTableViewCell
        cell.selectionStyle = .none
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2
        cell.profileImage.layer.borderWidth = 2
        cell.profileImage.layer.borderColor = UIColor.white.cgColor
        
        if(friendHigh.isHidden){
            cell.nameLabel.text = worldArray[indexPath.row].name.lowercased()
            if today == false {
                cell.scoreLabel.text = "\(worldArray[indexPath.row].highScore)"
            }else{
                cell.scoreLabel.text = "\(worldArray[indexPath.row].todayScore)"
            }
            cell.profileImage.downloadedFrom(link: worldArray[indexPath.row].imageURL)
        }else{
            cell.nameLabel.text = friendArray[indexPath.row].name.lowercased()
            if today == false {
                cell.scoreLabel.text = "\(friendArray[indexPath.row].highScore)"
            }else{
                cell.scoreLabel.text = "\(friendArray[indexPath.row].todayScore)"
            }
            
            cell.profileImage.downloadedFrom(link: friendArray[indexPath.row].imageURL)
        }
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
