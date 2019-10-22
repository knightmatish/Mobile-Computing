//
//  AppUserCell.swift
//  ChatApplication
//
//  Created by Yash on 10/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase

class AppUserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            if let _  = message?.text {
                detailTextLabel?.text = message?.text
            } else {
                detailTextLabel?.text = "📷 Photo"
            }
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timeStampDate)
            }
            
        }
    }
    
    private func setupNameAndProfileImage() {
        if let id = message?.chatPartnerID() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary =  snapshot.value as? [String:AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileImageURL = dictionary["profileImageURL"] as? String{
                        self.profileImageView.loadImageFromCache(withURLString: profileImageURL)
                    }
                    
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Move the names of the users to the right so that they do not overlap with the profile image
        textLabel?.frame = CGRect(x: 75, y: textLabel!.frame.origin.y , width: textLabel!.frame.width, height:  textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 75, y: detailTextLabel!.frame.origin.y + 5 , width: detailTextLabel!.frame.width, height:  detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_default_edit")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 28
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor =  #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        //Set the constraints for the custom profile image view
        profileImageView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        //Set the constraints for the custom time label
        timeLabel.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
