//
//  StoryItemCell.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class StoryItemCell: UICollectionViewCell {
	
	// MARK: - Public  Property
	var item: StoriesItem! {
		didSet {
            if let imageURL = item.account?.photo {
                addStoryButton.imageStory.loadImage(at: imageURL, low: imageURL, .w100, .w40)
            } else {
                addStoryButton.imageStory.image = nil
            }
			titleLabel.text = item.account?.username ?? ""
		}
	}
	
	var handleDetailStory: (() -> Void)?
	var handleGallery: (() -> Void)?
	
	let gradientLayer = CAGradientLayer()
    lazy var addStoryButton: AddStoryButton = {
        let addStoryBtn = AddStoryButton()
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedImageStory))
        addStoryBtn.addGestureRecognizer(imageTapGesture)
        return addStoryBtn
    }()

	lazy var titleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .Roboto(.extraBold, size: 12)
		label.textColor = .white
		return label
	}()
	
	lazy var subtitleLabel: UILabel = {
		let label: UILabel = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.textAlignment = .left
		label.font = .Roboto(.extraBold, size: 12)
		label.textColor = .white
		return label
	}()
		
    //MARK:: BUGFIX - Set Background View Gradient
    func setGradientBackground(colorTop: UIColor = .gradientStoryOne, colorBottom: UIColor = .gradientStoryTwo) {
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
		gradientLayer.locations = [0, 1]
        gradientLayer.cornerRadius = 12
		gradientLayer.frame = self.bounds
		
		
	}
	
	// MARK: - Public Method
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
        addSubview(addStoryButton)
        addStoryButton.iconPlusImage.isHidden = true
        addStoryButton.imageStory.stack(UIView(), UIView(), subtitleLabel, UIView(), titleLabel, alignment: .leading, distribution: .equalSpacing).padBottom(5).padLeft(10).padRight(5).padTop(5)
		
		//MARK:: BUGFIX - ADD Gradient Background
		setGradientBackground()
        clipsToBounds = true
        layer.cornerRadius = 11
        layer.insertSublayer(gradientLayer, at:0)
        
		setRead(true)
        clipsToBounds = false
	}
		
	//MARK:: BUGFIX - Check State Read View
	func setRead(_ read: Bool) {
        addStoryButton.removeFromSuperview()
        addSubview(addStoryButton)
        
        setGradientBackground(colorTop: read ? .gainsboro : .gradientStoryOne,
                              colorBottom: read ? .gainsboro : .gradientStoryTwo)
        
        addStoryButton.anchor(
            top: self.topAnchor,
            left: self.leftAnchor,
            bottom: self.bottomAnchor,
            right: self.rightAnchor,
            paddingTop: 3,
            paddingLeft: 3,
            paddingBottom: 3,
            paddingRight: 3
        )
	}
    
    func addGestureToDetail() {
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedImageStory))
        addStoryButton.addGestureRecognizer(imageTapGesture)
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		gradientLayer.frame = bounds
        addStoryButton.setUsernameOverlay()
	}
	
	@objc func handleWhenTappedImageStory() {
		self.handleDetailStory?()
	}
	
}
