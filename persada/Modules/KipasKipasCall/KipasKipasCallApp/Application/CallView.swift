//
//  CallView.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import KipasKipasShared

final class CallView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "KipasKipas\nCall App"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 32, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userLoginFullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fullname"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userLoginUserNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userLoginImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "AppIcon")
        view.layer.cornerRadius = 32
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.anchor(width: 64, height: 64)
        
        return view
    }()
    
    lazy var userLoginView: UIView = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Logged In As"
        title.textColor = .black
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.numberOfLines = 0
        
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.addSubviews([title, userLoginImageView, userLoginFullNameLabel, userLoginUserNameLabel])
        
        title.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12)
        userLoginImageView.anchor(top: title.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12)
        userLoginFullNameLabel.anchor(top: title.bottomAnchor, left: userLoginImageView.rightAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 12)
        userLoginUserNameLabel.anchor(top: userLoginFullNameLabel.bottomAnchor, left: userLoginImageView.rightAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 8)
        
        return view
    }()
    
    lazy var targetUserFullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fullname"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var targetUserNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var targetUserImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "AppIcon")
        view.layer.cornerRadius = 32
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.anchor(width: 64, height: 64)
        
        return view
    }()
    
    lazy var targetUserView: UIView = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Target"
        title.textColor = .black
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.numberOfLines = 0
        
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.addSubviews([title, targetUserImageView, targetUserFullNameLabel, targetUserNameLabel])
        
        title.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12)
        targetUserImageView.anchor(top: title.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 12)
        targetUserFullNameLabel.anchor(top: title.bottomAnchor, left: targetUserImageView.rightAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 12)
        targetUserNameLabel.anchor(top: targetUserFullNameLabel.bottomAnchor, left: targetUserImageView.rightAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 8)
        
        return view
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: UIControl.State())
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.anchor(height: 48)
        return button
    }()
    
    lazy var voiceCallButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Voice Call", for: UIControl.State())
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.anchor(height: 48)
        return button
    }()
    
    lazy var videoCallButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Video Call", for: UIControl.State())
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.anchor(height: 48)
        return button
    }()
    
    lazy var targetUserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Target", for: UIControl.State())
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.anchor(height: 48)
        return button
    }()
    
    lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [targetUserView, targetUserButton, videoCallButton, voiceCallButton, logoutButton])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 20
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews([titleLabel, userLoginView, actionView])
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 42, paddingLeft: 32, paddingRight: 32)
        userLoginView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 42, paddingLeft: 32, paddingRight: 32)
        actionView.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 32, paddingBottom: 42, paddingRight: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
