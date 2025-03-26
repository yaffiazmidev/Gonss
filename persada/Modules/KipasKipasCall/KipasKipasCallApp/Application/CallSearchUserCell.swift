//
//  CallSearchUserCell.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import KipasKipasCall
import Kingfisher

class CallSearchUserCell: UITableViewCell {
    lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fullname"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var userImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "AppIcon")
        view.layer.cornerRadius = 16
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.anchor(width: 32, height: 32)
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        
        addSubviews([userImageView, fullNameLabel, userNameLabel])
        userImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4)
        fullNameLabel.anchor(top: topAnchor, left: userImageView.rightAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 2, paddingRight: 8)
        userNameLabel.anchor(top: fullNameLabel.bottomAnchor, left: userImageView.rightAnchor, right: rightAnchor, paddingTop: 2, paddingLeft: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(profile: CallProfile) {
        if let photo = profile.photo, let url = URL(string: photo) {
            userImageView.kf.setImage(with: url)
        }
        
        fullNameLabel.text = profile.name
        userNameLabel.text = profile.username
    }
}
