//
//  SubcommentHeaderView.swift
//  Persada
//
//  Created by NOOR on 26/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class SubcommentHeaderView: UICollectionReusableView {
	
	var subcomment: CommentHeaderCellViewModel? {
		didSet {
			guard let subcomment = subcomment else { return }
			
			nameLabel.text = subcomment.username
			descriptionLabel.text = subcomment.description
			if subcomment.imageUrl != "" {
				imageProfile.loadImage(at: subcomment.imageUrl ?? "")
			}

			dateLabel.text = Date(timeIntervalSince1970: TimeInterval((subcomment.date ?? 1000)/1000 )).timeAgoDisplay()
		}
	}
	
	var mentionHandler: ((_ text: String,_ type: wordType) -> Void)?
	
	lazy var imageProfile: UIImageView = {
		let imageview = UIImageView(image: UIImage(named: String.get(.empty)))
		imageview.contentMode = .scaleAspectFill
		imageview.layer.masksToBounds = false
		imageview.layer.cornerRadius = 30
		imageview.clipsToBounds = true
		return imageview
	}()
	
	let nameLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .Roboto(.bold, size: 12)
		return label
	}()
	
	let dateLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.font = .Roboto(.regular, size: 12)
		return label
	}()
	
	lazy var descriptionLabel: AttrTextView = {
		let textView = AttrTextView()
		textView.font = .Roboto(.regular, size: 12)
		textView.backgroundColor = .whiteSmoke
		textView.textColor = .black
		textView.isScrollEnabled = false
        textView.isEditable = false
		return textView
	}()

	var containerView = UIView()
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		addSubview(containerView)
		containerView.backgroundColor = .whiteSmoke
		[imageProfile, dateLabel, descriptionLabel, nameLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			containerView.addSubview($0)
		}
		
		imageProfile.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil,
							paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
		nameLabel.anchor(top: containerView.topAnchor, left: imageProfile.rightAnchor, bottom: nil, right: nil,
						 paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 150, height: 30)
		dateLabel.anchor(top: nameLabel.bottomAnchor, left: imageProfile.rightAnchor, bottom: nil, right: containerView.rightAnchor,
						 paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 30)
		descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4).isActive = true
		descriptionLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
		descriptionLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16).isActive = true
		descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: 0).isActive = true

		containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	} 
}

