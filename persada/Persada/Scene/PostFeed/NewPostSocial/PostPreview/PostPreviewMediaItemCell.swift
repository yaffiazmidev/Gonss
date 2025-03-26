//
//  PostPreviewMediaItemCell.swift
//  Persada
//
//  Created by movan on 14/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class PostPreviewMediaItemCell: UICollectionViewCell {
	
	// MARK: - Public  Property
	
	lazy var imageView: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.isUserInteractionEnabled = true
		return image
	}()
	
	let containerView: UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(imageView)
//		containerView.fillSuperview()
//
//		containerView.addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

