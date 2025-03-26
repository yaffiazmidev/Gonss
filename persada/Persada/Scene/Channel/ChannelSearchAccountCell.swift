//
//  ChannelSearchAccountCell.swift
//  Persada
//
//  Created by Muhammad Noor on 18/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Kingfisher

class ChannelSearchAccountCell: UICollectionViewCell {
	
	// MARK:- Public Property
	
	var data: SearchAccount? {
		didSet {
			nameLabel.text = data?.name
            usernameLabel.text = data?.username == nil ? "" : "@\(data!.username!)"
            verifiedIcon.isHidden = data?.isVerified != true
            
            if let photo = data?.photo, !photo.isEmpty {
                //bg.kf.indicatorType = .activity
                //bg.kf.setImage(with: URL(string: photo), placeholder: UIImage.defaultProfileImageCircle)
                bg.loadImage(at: photo, .w100, emptyImageName: "default-profile-image-circle")
            } else {
                bg.image = .defaultProfileImageCircle
            }
		}
	}
	
	// MARK:- Private Property
	
	private let bg: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 21
        iv.withBorder(width: 2, color: .whiteSnow)
		return iv
	}()
    
    private lazy var verifiedIcon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: .get(.iconVerified))
        return view
    }()
	
	private var nameLabel: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.textAlignment = .left
		lbl.textColor = .contentGrey
		lbl.textAlignment = .left
        lbl.font = .Roboto(.bold, size: 14)
		lbl.numberOfLines = 1
		return lbl
	}()
    
    private var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .grey
        label.font = .Roboto(.regular, size: 12)
        label.numberOfLines = 1
        return label
    }()
    
    private var userLabelView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        return view
    }()
	
	private lazy var buttonFollow: BadgedButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 20
		button.layer.masksToBounds = false
		button.setTitleColor(UIColor.init(hexString: "#BC1C22"), for: .normal)
		button.backgroundColor = UIColor.init(hexString: "#FAFAFA")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
		button.titleLabel?.textColor = .red
		button.isHidden = true
		button.setImage(#imageLiteral(resourceName: "Union").withRenderingMode(.alwaysOriginal), for: .normal)
		button.setTitle("Follow", for: .normal)
		return button
	}()
	
	// MARK:- Public Method
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		layer.masksToBounds = false
		layer.cornerRadius = 10
        backgroundColor = .clear
		
		contentView.addSubview(bg)
		bg.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 42, height: 42)
		bg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(verifiedIcon)
        verifiedIcon.anchor(bottom: bg.bottomAnchor, right: bg.rightAnchor, width: 16, height: 16)
        verifiedIcon.isHidden = true
		
		contentView.addSubview(buttonFollow)
		buttonFollow.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 80, height: 30)
		buttonFollow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		
		contentView.addSubview(userLabelView)
        userLabelView.addArrangedSubviews([nameLabel, usernameLabel])
		userLabelView.anchor(top: nil, left: bg.rightAnchor, bottom: nil, right: buttonFollow.leftAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40)
		userLabelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

