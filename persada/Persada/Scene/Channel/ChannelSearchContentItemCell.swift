//
//  ChannelSearchContentItemCell.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChannelSearchContentItemCell: UICollectionViewCell {
	
	var item: Feed? {
		didSet {
			guard let item = item, let imageURL = item.post?.medias?.first?.thumbnail?.medium else { return }
            bg.loadImage(at: imageURL, .w240)
		}
	}
	
	lazy var bg: UIImageView = {
		let iv = UIImageView()
		iv.translatesAutoresizingMaskIntoConstraints = false
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 12
		return iv
	}()
	
	var nameLabel: UILabelPadding = {
		let label = UILabelPadding()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.backgroundColor = .primary
		label.textColor = .white
		label.font = UIFont.boldSystemFont(ofSize: 20)
		label.numberOfLines = 0
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		
		contentView.addSubview(bg)
		bg.fillSuperview()
		
		bg.addSubview(nameLabel)
		let width = UIScreen.main.bounds.width / 2 - 40
		nameLabel.anchor(top: nil, left: bg.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: width, height: 30)
		nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(_ media: Medias?) {
		guard let media = media, let url = media.url else {
			return
		}
		
		bg.loadImage(at: url)
	}
	
	func configureExplore(with: Feed?) {
		guard let media = with?.post?.medias?.first, let url = media.url else {
				return
			}
			
        bg.loadImage(at: url, .w240)
	}
}
