//
//  ChatMessageCell.swift
//  ChatApplication
//
//  Created by Yash, Nitish, Nakia, Suraj and Krishna on 12/8/19.
//  Copyright © 2019 Yash, Nitish, Nakia, Suraj and Krishna. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    weak var chatLogController: ChatLogController?
    
    static let  blueColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    
    let dateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        //label.layer.cornerRadius = 15
        //label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    lazy var explicitContentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sensitive_content")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.6
        return imageView
    }()
    
    let explicitContentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.alpha = 0.6
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Obscene Content"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    let textView: UITextView = {
        let textLabel = UITextView()
        textLabel.isEditable = false
        textLabel.text = "Placeholder Text"
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.text = "HH:MM AM"
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var seePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.setTitle("See Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSeePhoto), for: .touchUpInside)
        button.alpha = 0.6
        return button
    }()
    
    let seePhotoSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        return view
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer ) {
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    @objc func handleSeePhoto() {
        // See Photo logic
        unsetMask()
    }
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor:NSLayoutConstraint?
    var bubbleViewHeightAnchor:NSLayoutConstraint?
    var dateViewHeightAnchor:NSLayoutConstraint?
    
    fileprivate func setupShadowView() {
        shadowView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        shadowView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        shadowView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        shadowView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        shadowView.isHidden = true
        
        //Add the blur view to the shadow view and set its constraints
        shadowView.addSubview(blurView)
        blurView.leftAnchor.constraint(equalTo: shadowView.leftAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        blurView.widthAnchor.constraint(equalTo: shadowView.widthAnchor).isActive = true
        blurView.heightAnchor.constraint(equalTo: shadowView.heightAnchor).isActive = true
        
        //Add the see photo button to the shadow view and set its constraints
        shadowView.addSubview(seePhotoButton)
        seePhotoButton.leftAnchor.constraint(equalTo: shadowView.leftAnchor).isActive = true
        seePhotoButton.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        seePhotoButton.widthAnchor.constraint(equalTo: shadowView.widthAnchor).isActive = true
        seePhotoButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        //Add see photo separator view to the shadow view and set its constraints
        shadowView.addSubview(seePhotoSeperatorView)
        seePhotoSeperatorView.centerXAnchor.constraint(equalTo: seePhotoButton.centerXAnchor).isActive = true
        seePhotoSeperatorView.bottomAnchor.constraint(equalTo: seePhotoButton.topAnchor).isActive = true
        seePhotoSeperatorView.widthAnchor.constraint(equalTo: seePhotoButton.widthAnchor, constant: -8).isActive = true
        seePhotoSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Add explicit content imageView view to the shadow view and set its constraints
        shadowView.addSubview(explicitContentImageView)
        explicitContentImageView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor).isActive = true
        explicitContentImageView.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor,constant: -40).isActive = true
        explicitContentImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        explicitContentImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //explicitContentLabel
        shadowView.addSubview(explicitContentLabel)
        explicitContentLabel.topAnchor.constraint(equalTo: explicitContentImageView.bottomAnchor).isActive = true
        explicitContentLabel.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor).isActive = true
        explicitContentLabel.widthAnchor.constraint(equalTo:shadowView.heightAnchor).isActive = true
        explicitContentLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(timestampLabel)
        bubbleView.addSubview(shadowView)
        setupDateView()
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        setupShadowView()
        
        // set constartints
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: dateView.bottomAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleViewHeightAnchor = bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor,constant: -40)
        bubbleViewHeightAnchor?.isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 6).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        timestampLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -16).isActive = true
        timestampLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4).isActive = true
        timestampLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
        timestampLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupDateView() {
        dateView.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: dateView.topAnchor).isActive = true
        
        // dateLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // dateLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: dateView.leftAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: dateView.rightAnchor).isActive = true
        
        addSubview(dateView)
        dateView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        dateView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor).isActive = true
        dateView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor).isActive = true
        dateViewHeightAnchor = dateView.heightAnchor.constraint(equalToConstant: 40)
        dateViewHeightAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMask()
    {
        shadowView.isHidden = false
    }
    
    func unsetMask() {
        shadowView.isHidden = true
    }
    
    func removeDateView() {
        dateViewHeightAnchor?.constant = 0
        dateView.isHidden = true
        bubbleViewHeightAnchor?.constant = 0
    }
    
    func displayDateView() {
        dateViewHeightAnchor?.constant = 40
        dateView.isHidden = false
        bubbleViewHeightAnchor?.constant = -40
    }
    
}
