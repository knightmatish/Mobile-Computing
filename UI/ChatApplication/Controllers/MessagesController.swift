//
//  ViewController.swift
//  Chat
//
//  Created by Yash on 4/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class MessagesController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    
    let cellId = "cellId "
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Users", style: .plain, target: self, action: #selector(handleNewMessage))
        
        //Check if the user is logged in
        checkIfUserIsLoggedIn()
        
        tableView.register(AppUserCell.self, forCellReuseIdentifier: cellId)
        
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 999
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            updateUserLocation(location: currentLocation, uid: uid)
        }
    }
    
    func updateUserLocation(location: CLLocation, uid: String) {
        let rootRef = Database.database().reference()
        let geoRef = GeoFire(firebaseRef: rootRef.child("user_locations"))
        //update users location
        geoRef.setLocation(location, forKey: uid)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessage(withMessageId: messageID)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchMessage(withMessageId messageID: String) {
        let messagesReference =  Database.database().reference().child("messages").child(messageID)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerID = message.chatPartnerID() {
                    self.messagesDictionary[chatPartnerID] = message
                }
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (messageX, messageY) -> Bool in
            return messageX.timeStamp?.intValue ?? 0 > messageY.timeStamp?.intValue ?? 0
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for:  indexPath) as! AppUserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Get the details of the selected app users
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            //show the chat log for the selected app user
            let appUser = AppUser()
            appUser.uid =  chatPartnerId
            appUser.setValuesForKeys(dictionary)
            self.showChatController(forAppUser: appUser)
        }, withCancel: nil)
    }
    
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.modalPresentationStyle = .fullScreen
        newMessageController.messagesController = self 
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            //The user is not logged in
            perform(#selector(handleLogout),with: nil,afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }

    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userData = snapshot.value as? [String:AnyObject]{
                //Set the title and display image of the navigation bar on the messages page to that of the logged in user
                let appUser = AppUser()
                appUser.name = userData["name"] as? String
                appUser.email = userData["email"] as? String
                appUser.profileImageURL = userData["profileImageURL"] as? String
                self.setupNavBar(withAppUser: appUser)
                
            }
        }, withCancel: nil)
    }
    
    func setupNavBar(withAppUser appUser : AppUser){
        //Clear the messages of the previously logged in user
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        //Get the messages of the current user
        observeUserMessages()
        
        let titleView = UIView()
        //let tap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
        //tap.numberOfTapsRequired = 1
        //titleView.addGestureRecognizer(tap)
        //titleView.isUserInteractionEnabled = true
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        if let profilerUmageUrl = appUser.profileImageURL {
            profileImageView.loadImageFromCache(withURLString: profilerUmageUrl)
        }
        
        titleView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: titleView.heightAnchor,multiplier: 0.9).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: titleView.heightAnchor,multiplier: 0.9).isActive = true
        
        let nameLabel = UILabel()
        titleView.addSubview(nameLabel)
        nameLabel.text = appUser.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo : profileImageView.heightAnchor).isActive = true
       
        self.navigationItem.titleView = titleView
    }
    
    @objc func showChatController(forAppUser appUser : AppUser){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.appUser = appUser
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout()
    {
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        let loginController = LoginViewController()
        loginController.modalPresentationStyle = .fullScreen
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil )
    }
    
}

