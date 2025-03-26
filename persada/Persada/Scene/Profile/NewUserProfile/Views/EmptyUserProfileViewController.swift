//
//  EmptyUserProfileViewController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class EmptyUserProfileViewController: UIViewController {
	
	lazy var userImageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		let placeholderImage = UIImage(named: "placeholderUserImage")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.masksToBounds = false
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.gainsboro.cgColor
		imageView.backgroundColor = .whiteSnow
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = 16
		imageView.clipsToBounds = true
		imageView.image = placeholderImage
		return imageView
	}()
	
	let nameLabel: UILabel = UILabel(text: .get(.unknown), font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
	var usernameLabel: UILabel = UILabel(text: .get(.unknown), font: .Roboto(.medium, size: 14), textColor: .contentGrey, textAlignment: .left, numberOfLines: 1)

	let postingLabel : UILabel = UILabel(text: .get(.posting), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	let totalPostLabel: UILabel = UILabel(text: "0", font: .Roboto(.bold, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
	lazy var followingLabel : UILabel =  UILabel(text: .get(.following), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	lazy var followerLabel: UILabel = UILabel(text: .get(.follower), font: .Roboto(.regular, size: 12), textColor: .gray, textAlignment: .left, numberOfLines: 1)
	
	let emptyLabel: UILabel = {
		let label = UILabel(text: .get(.userNotFound), font: .Roboto(.regular, size: 16), textColor: .gainsboro, textAlignment: .center, numberOfLines: 0)
		label.backgroundColor = .whiteSnow
		label.translatesAutoresizingMaskIntoConstraints = false
		label.layer.masksToBounds = false
		label.layer.borderColor = UIColor.gainsboro.cgColor
		label.layer.borderWidth = 1
		return label
	}()
		
	
	lazy var totalFollowerLabel: UILabel = {
		let label = UILabel(text: "0", font: .Roboto(.bold, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
		return label
	}()
	
	lazy var totalFollowingLabel: UILabel = {
		let label = UILabel(text: "0", font: .Roboto(.bold, size: 16), textColor: .black, textAlignment: .left, numberOfLines: 1)
		return label
	}()
	
	lazy var optionIconButton: UIButton = {
		let imageView = UIButton(type: .system)
		imageView.setImage(UIImage(named: String.get(.iconEllipsis)), for: .normal)
		imageView.backgroundColor = .white
		return imageView
	}()
	
	lazy var stackStatusView: UIStackView = {
		
		let postingCountView = UIStackView(arrangedSubviews: [postingLabel, totalPostLabel])
		postingCountView.axis = .vertical
		postingCountView.addSubview(postingLabel)
		postingCountView.addSubview(totalPostLabel)
		
		let followerCountView = UIStackView(arrangedSubviews: [followerLabel, totalFollowerLabel])
		followerCountView.axis = .vertical
		followerCountView.addSubview(followerLabel)
		followerCountView.addSubview(totalFollowerLabel)
		
		let followingCountView = UIStackView(arrangedSubviews: [followingLabel, totalFollowingLabel])
		followingCountView.axis = .vertical
		followingCountView.addSubview(followingLabel)
		followingCountView.addSubview(totalFollowingLabel)
		
		[postingLabel, totalPostLabel, followerLabel, totalFollowerLabel, followingLabel, totalFollowingLabel].forEach {
			$0.backgroundColor = .whiteSnow
		}
		
		let stackView =  UIStackView(arrangedSubviews: [postingCountView, followerCountView, followingCountView])
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = 24
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		return stackView
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .whiteSnow
		[userImageView, nameLabel, usernameLabel, optionIconButton].forEach {
			view.addSubview($0)
			$0.backgroundColor = .whiteSnow
		}
		
		userImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 82, height: 82)
		
		nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: userImageView.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, height: 20)
		
		usernameLabel.anchor(top: nameLabel.bottomAnchor, left: userImageView.rightAnchor, paddingTop: 2, paddingLeft: 20, height: 20)
		
		optionIconButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 32, height: 32)
		
		view.addSubview(stackStatusView)
		view.addSubview(emptyLabel)
		stackStatusView.anchor(top: usernameLabel.topAnchor, left: userImageView.rightAnchor, paddingTop: 25, paddingLeft: 20, paddingRight: 24)
		
		emptyLabel.anchor(top: stackStatusView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
	}
}
