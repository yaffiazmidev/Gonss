//
//  ProfileUserHeaderView.swift
//  Persada
//
//  Created by Muhammad Noor on 14/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import KipasKipasShared

class ProfileUserHeaderView: UIView {
    
    // MARK:- Public Property
    
    var item: Profile? {
        didSet {
					imageProfile.loadImage(at: item?.photo ?? "")
            nameLabel.text = item?.name
            usernameLabel.text = item?.username
            buttonMoreOption.isHidden = getIdUser() != item?.id
            buttonFollow.isHidden = item?.isFollow ?? false
            iconVerified.isHidden = !(item?.isVerified ?? false) 
        }
    }
    
    var followers: Int! {
        didSet {
            followerLabel.text = "\(followers ?? 0)\nFollower"
        }
    }
    var followings: Int! {
        didSet {
            followingLabel.text = "\(followings ?? 0)\nFollowing"
        }
    }

    let nameLabel = UILabel(text: "Follower makan", textColor: .black)
    let usernameLabel = UILabel(text: "@asdfas", textColor: .black)
    var handleProfileMenu: (() -> Void)?
    var handleFollow: ((_ value: String) -> Void)?
    var onProfileImageTapped: (() -> Void)?

    lazy var imageProfile: UIImageView = {
        let img = UIImageView(image: .defaultProfileImageLargeCircle)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.layer.cornerRadius = 35
        return img
    }()
    
    lazy var iconVerified: UIImageView = {
        let img = UIImageView(image: UIImage(named: "iconVerified"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.masksToBounds = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.isHidden = true
        return img
    }()

    lazy var buttonWeLike: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor.init(hexString: "#FAFAFA", alpha: 1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.layer.masksToBounds = false
        button.setTitle("We like 3 thing", for: .normal)
        button.addTarget(self, action: #selector(handleWeLikeButton), for: .touchUpInside)
        button.setTitleColor(.darkGray, for: .normal)
        return button
    }()
    
    lazy var buttonFollow: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .red
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleFollowButton), for: .touchUpInside)
        button.layer.masksToBounds = false
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    lazy var buttonMoreOption: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleMoreOption), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "iconReport"), for: .normal)
        return button
    }()

    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.text = "Bukan manusias biasa"
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()

    let followerLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.text = "183\nFollower"
        lbl.numberOfLines = 0
        return lbl
    }()

    let followingLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.text = "12\nFollowing"
        lbl.numberOfLines = 0
        return lbl
    }()

    let viewFrame = UIView()

    // MARK: - Public Method

    override func draw(_ rect: CGRect) {
        backgroundColor = .white
        addSubview(viewFrame)
        viewFrame.translatesAutoresizingMaskIntoConstraints = false
        viewFrame.fillSuperviewSafeAreaLayoutGuide()
        viewFrame.backgroundColor = .white

        let stackViewStatus = UIStackView(arrangedSubviews: [followerLabel, followingLabel, UIView()])
        stackViewStatus.distribution = .fillEqually
        stackViewStatus.axis = .horizontal
        stackViewStatus.spacing = 15

        let stackViewFollow = UIStackView(arrangedSubviews: [buttonWeLike, buttonFollow, UIView()])
        stackViewFollow.distribution = .fillProportionally
        stackViewFollow.axis = .horizontal
        stackViewFollow.spacing = 15

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        imageProfile.addGestureRecognizer(gestureRecognizer)
        
        viewFrame.addSubview(imageProfile)
        viewFrame.addSubview(iconVerified)
        viewFrame.addSubview(buttonMoreOption)
        viewFrame.addSubview(descriptionLabel)
        viewFrame.addSubview(usernameLabel)
        viewFrame.addSubview(nameLabel)
        viewFrame.addSubview(stackViewStatus)
        viewFrame.addSubview(buttonWeLike)
        viewFrame.addSubview(buttonFollow)

        imageProfile.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 70, height: 70)
        nameLabel.anchor(top: viewFrame.topAnchor, left: imageProfile.rightAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 150, height: 30)
        usernameLabel.anchor(top: nameLabel.bottomAnchor, left: imageProfile.rightAnchor, bottom: nil, right: nil, paddingTop: 1, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 100, height: 20)
        iconVerified.anchor(top: nameLabel.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 1, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 10, height: 10)
        
        buttonMoreOption.anchor(top: viewFrame.topAnchor, left: nil, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 30, height: 30)

        stackViewStatus.anchor(top: usernameLabel.bottomAnchor, left: usernameLabel.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)

        descriptionLabel.anchor(top: stackViewStatus.bottomAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)

        buttonWeLike.anchor(top: descriptionLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 150, height: 40)
        
        buttonFollow.anchor(top: descriptionLabel.bottomAnchor, left: buttonWeLike.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 130, height: 40)
    }
    
    @objc private func handleFollowButton() {
        self.handleFollow?(item?.id ?? "")
    }

    @objc private func handleWeLikeButton() {

    }

    @objc private func handleMoreOption() {
        self.handleProfileMenu?()
    }
    
    @objc private func profileImageTapped() {
        onProfileImageTapped?()
    }
}
