//
//  PostItemCell.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class PostItemCell: UICollectionViewCell {
	
	// MARK: - Public  Property
	
	lazy var imageView: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.layer.masksToBounds = true
		image.isUserInteractionEnabled = true
		image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFit
		let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.handleAddMedia))
        image.addGestureRecognizer(imageTapGesture)
		return image
	}()
    
    lazy var iconView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.isUserInteractionEnabled = true
        image.layer.cornerRadius = 8
        let imageTapGesture = UITapGestureRecognizer(target:self,action:#selector(self.handleAddMedia))
        image.addGestureRecognizer(imageTapGesture)
        return image
    }()

	// MARK: - Public Method
	
	var handleMedia: (() -> Void)?
	
	// MARK: - Public Method
		
	override func draw(_ rect: CGRect) {
		super.draw(rect)
        
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.black25.cgColor
        self.layer.cornerRadius = 8
        self.backgroundColor = .clear

		addSubview(imageView)
        addSubview(iconView)
		imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        NSLayoutConstraint.activate([
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 20)
        ])
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
        self.isUserInteractionEnabled = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleAddMedia() {
		self.handleMedia?()
	}
	
}
