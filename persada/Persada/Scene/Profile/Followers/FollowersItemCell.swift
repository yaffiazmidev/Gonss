//
//  FollowersItemCell.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Kingfisher
import KipasKipasShared

class FollowersItemCell: UITableViewCell {
	
	// MARK:- Public Property
	
	var data: Follower? {
		didSet {
			
			guard let data = data, let isFollow = data.isFollow else {
				return
			}
            
            if data.photo?.isUrl() ?? false {
                bg.kf.indicatorType = .activity
                bg.kf.setImage(with: URL(string: data.photo ?? ""), placeholder: UIImage.defaultProfileImageCircle)
            } else {
                bg.image = .defaultProfileImageCircle
            }
 			nameLabel.text = data.name
            usernameLabel.text = data.username ?? ""
            buttonStack.isHidden = data.id == getIdUser()
			configureStatus(isFollow)
		}
	}
	
	var handlerFollow: (() -> Void)?
	var handlerTappedImageView: (() -> Void)?
    var handlerRemoveFollower: (() -> Void)?
	
	// MARK:- Private Property
	
    private let stackView = UIStackView()
    private let nameStack: UIStackView = UIStackView()
    private let buttonStack: UIStackView = UIStackView()
	private(set) lazy var bg: UIImageView = UIImageView()
	private(set) var nameLabel: UILabel = UILabel()
    private(set) var usernameLabel: UILabel = UILabel()
    private(set) lazy var followButton: PrimaryButton = PrimaryButton(type: .system)
    private(set) lazy var optionButton: UIButton = UIButton(type: .system)
	
	// MARK:- Public Method
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
        configureUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    private func configureUI() {
        backgroundColor = .white
        UIFont.loadCustomFonts
        configureImage()
        configureButtonStack()
        configureStack()
    }
    
    private func configureButtonStack() {
        contentView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.alignment = .fill
        buttonStack.distribution = .fill
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.anchors.width.equal(100)
        buttonStack.anchors.height.equal(30)
        buttonStack.anchors.centerY.equal(contentView.anchors.centerY)
        buttonStack.anchors.trailing.equal(contentView.safeAreaLayoutGuide.anchors.trailing)
        
        configureFollowButton()
        configureOptionButton()
    }
    
    private func configureStack() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.backgroundColor = .white
        let gesture = UITapGestureRecognizer(target: self, action: #selector(whenTappedImageView))
        stackView.addGestureRecognizer(gesture)
        
        stackView.anchors.leading.equal(bg.anchors.trailing, constant: 12)
        stackView.anchors.trailing.equal(buttonStack.anchors.leading, constant: -12)
        stackView.anchors.centerY.equal(contentView.anchors.centerY)
        
        configureImage()
        configureNameStack()
    }
	
    private func configureImage() {
        contentView.addSubview(bg)
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.cornerRadius = 27
        bg.contentMode = .scaleAspectFill
        bg.isUserInteractionEnabled = true
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.layer.masksToBounds = false
        bg.clipsToBounds = true
        bg.withWidth(54)
        bg.withHeight(54)
        bg.anchors.leading.equal(contentView.anchors.leading)
        bg.anchors.centerY.equal(contentView.anchors.centerY)

    }
    
    private func configureNameStack() {
        stackView.addArrangedSubview(nameStack)
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.alignment = .fill
        nameStack.distribution = .fill
        nameStack.axis = .vertical
        
        configureNameLabel()
        configureUsernameLabel()
    }
    
    private func configureNameLabel() {
        nameStack.addArrangedSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .roboto(.medium, size: 14)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.layer.masksToBounds = false
        nameLabel.clipsToBounds = true
    }
    
    private func configureUsernameLabel() {
        nameStack.addArrangedSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .roboto(.regular, size: 12)
        usernameLabel.textColor = .grey
        usernameLabel.textAlignment = .left
        usernameLabel.numberOfLines = 0
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.layer.masksToBounds = false
        usernameLabel.clipsToBounds = true
    }
    
    private func configureFollowButton() {
        buttonStack.addArrangedSubview(followButton)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.layer.cornerRadius = 4
        followButton.setTitle(.get(.follow), for: .normal)
        followButton.addTarget(self, action: #selector(whenTappedFollowButton), for: .touchUpInside)
        followButton.anchors.width.equal(70)
    }
    
    private func configureOptionButton() {
        buttonStack.addArrangedSubview(optionButton)
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage.iconHorizontalElipsisGrey
        image?.withTintColor(.black)
        optionButton.setImage(image)
        optionButton.addTarget(self, action: #selector(whenTappedRemoveFollowers), for: .touchUpInside)
    }
    
	@objc private  func whenTappedFollowButton() {
		self.handlerFollow?()
	}
	
    @objc private func whenTappedImageView() {
		self.handlerTappedImageView?()
	}
	
    @objc private func whenTappedRemoveFollowers() {
        self.handlerRemoveFollower?()
    }
    
	func configureStatus(_ status: Bool) {
		followButton.titleLabel?.textAlignment = .natural
		followButton.contentVerticalAlignment = .center
		if status == true {
			followButton.setup(color: .whiteSmoke, textColor: .contentGrey, font: .roboto(.medium, size: 12))
			followButton.setTitle("Mengikuti", for: .normal)
		} else {
			followButton.setup(color: .primary, textColor: .white, font: .roboto(.medium, size: 12))
			followButton.setTitle("Follow", for: .normal)
		}
	}
}

