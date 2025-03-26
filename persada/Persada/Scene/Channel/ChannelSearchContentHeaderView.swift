//
//  ChannelSearchContentHeaderView.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChannelSearchContentHeaderView: UICollectionReusableView {
	static let reuseIdentifier = "header-reuse-identifier"
	
	lazy var label: UILabel = {
		let label: UILabel = UILabel()
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.boldSystemFont(ofSize: 14)
		label.text = "For You"
		label.textColor = .black
		label.textAlignment = .left
        label.isHidden = true
		return label
	}()
	
	lazy var imageUser: UIImageView = {
		let image = UIImageView(frame: .zero)
		image.layer.cornerRadius = 20
		image.image = UIImage(named: .get(.empty))
		image.backgroundColor = .gray
		image.clipsToBounds = true
		image.contentMode = .scaleToFill
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedGesture))
        image.addGestureRecognizer(gesture)
		image.isUserInteractionEnabled = true
		return image
	}()
	
	lazy var imageView: UIView = {
		let view: UIView = UIView()
		view.clipsToBounds = true
		view.addSubview(imageUser)
		imageUser.fillSuperviewSafeAreaLayoutGuide()
		return view
	}()
	
	var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 13)
		label.text = "Sport"
		label.textColor = .black
		return label
	}()
	
	
	var descLabel: UILabel = {
		let label: UILabel = UILabel()
		label.text = "This channel is all about sport's things that alot of people talk"
		label.font = UIFont.boldSystemFont(ofSize: 10)
		label.numberOfLines = 0
		label.textColor = .black
		return label
	}()
	
	var followButton: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setup(font: .Roboto(.bold, size: 16))
		button.setTitle("Follow", for: .normal)
        button.addTarget(self, action: #selector(handleWhenTappedFollowButton), for: .touchUpInside)
		return button
	}()
	
	lazy var descriptionView: UIView = {
		let view: UIView = UIView()
		view.isUserInteractionEnabled = true
        followButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.stack(titleLabel, descLabel, UIView(), followButton, spacing: 4, alignment: .fill, distribution: .fill)
		
		return view
	}()
	
    var handleFollow: (() -> Void)?
    var handleDetailChannel: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(imageView)
		
		backgroundColor = .clear
		[label, descriptionView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		label.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor,
								 paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 32)
		
		let width = (UIScreen.main.bounds.width / 2) - 16
		
        imageView.anchor(top: label.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil,
										 paddingTop: 8, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: width, height: 0)
		descriptionView.anchor(top: label.bottomAnchor, left: imageUser.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
													 paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func configure(post: Channel?) {
		guard let post = post else {
			return
		}
		
		titleLabel.text = post.name ?? ""
		descLabel.text = post.descriptionField ?? ""
		imageUser.loadImage(at: post.photo ?? "")
	}
	
    @objc func handleWhenTappedGesture() {
        self.handleDetailChannel?()
    }
    
    @objc private func handleWhenTappedFollowButton() {
        self.handleFollow?()
    }
}




