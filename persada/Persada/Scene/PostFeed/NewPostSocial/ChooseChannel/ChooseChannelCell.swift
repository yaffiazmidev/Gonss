//
//  PostSocialChooseChannelCell.swift
//  Persada
//
//  Created by Muhammad Noor on 14/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChooseChannelCell: UICollectionViewCell {
	
	var data: Channel? {
		didSet {
			bg.loadImage(at: data?.photo ?? "")
			nameLabel.text = data?.name
		}
	}
	
	private let bg: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 25
		return iv
	}()
	
	var nameLabel: UILabel = {
		let lbl = UILabel()
		lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.textAlignment = .center
		lbl.textColor = .darkGray
		lbl.textAlignment = .left
		lbl.font = UIFont.boldSystemFont(ofSize: 14)
		lbl.numberOfLines = 0
		return lbl
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		layer.masksToBounds = false
		layer.cornerRadius = 10
		backgroundColor = .whiteSnow
		
		[bg, nameLabel].forEach { (view) in
			contentView.addSubview(view)
		}
		
		bg.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 50, height: 50)
		bg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		
		nameLabel.anchor(top: nil, left: bg.rightAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 40)
		nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
