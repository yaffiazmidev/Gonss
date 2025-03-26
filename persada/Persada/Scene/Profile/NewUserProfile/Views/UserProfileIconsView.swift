//
//  UserProfileIconsView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 12/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit


class UserProfileIconsView: UIView {
	
	var icons = [
		UIImageView(image: UIImage(named: .get(.iconNonActiveInstagram))!),
		UIImageView(image: UIImage(named: .get(.iconNonActiveTiktok))!),
		UIImageView(image: UIImage(named: .get(.iconNonActiveWikipedia))!),
		UIImageView(image: UIImage(named: .get(.iconNonActiveFacebook))!),
		UIImageView(image: UIImage(named: .get(.iconNonActiveTwitter))!)
	]
    
    var iconsActive = [
        UIImageView(image: UIImage(named: .get(.iconActiveInstagram))!),
        UIImageView(image: UIImage(named: .get(.iconActiveTiktok))!),
        UIImageView(image: UIImage(named: .get(.iconActiveWikipedia))!),
        UIImageView(image: UIImage(named: .get(.iconActiveFacebook))!),
        UIImageView(image: UIImage(named: .get(.iconActiveTwitter))!)
    ]
	
	var handlerInstagram: (() -> Void)?
	var handlerTiktok: (() -> Void)?
    var handlerWikipedia: (() -> Void)?
	var handlerFacebook: (() -> Void)?
	var handlerTwitter: (() -> Void)?
	
	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
		let collectView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectView.translatesAutoresizingMaskIntoConstraints = false
		collectView.registerCustomCell(IconsCell.self)
		collectView.backgroundColor = .white
        collectView.isScrollEnabled = false
		return collectView
	}()
	
	var dataSource = [
		SocialMedia(socialMediaType: SocialMediaType.instagram.rawValue, urlSocialMedia: ""),
		SocialMedia(socialMediaType: SocialMediaType.tiktok.rawValue, urlSocialMedia: ""),
		SocialMedia(socialMediaType: SocialMediaType.wikipedia.rawValue, urlSocialMedia: ""),
		SocialMedia(socialMediaType: SocialMediaType.facebook.rawValue, urlSocialMedia: ""),
		SocialMedia(socialMediaType: SocialMediaType.twitter.rawValue, urlSocialMedia: ""),
	]
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = .black
		
		let gestureInstagram = UITapGestureRecognizer(target: self, action: #selector(handleGestureInstagram(_:)))
		let gestureTiktok = UITapGestureRecognizer(target: self, action: #selector(handleGestureTiktok(_:)))
		let gestureWikipedia = UITapGestureRecognizer(target: self, action: #selector(handleGestureWikipedia(_:)))
		let gestureFacebook = UITapGestureRecognizer(target: self, action: #selector(handleGestureFacebook(_:)))
		let gestureTwitter = UITapGestureRecognizer(target: self, action: #selector(handleGestureTwitter(_:)))
		
		icons.forEach {
			$0.isUserInteractionEnabled = true
		}
		
		icons[0].addGestureRecognizer(gestureInstagram)
		icons[1].addGestureRecognizer(gestureTiktok)
		icons[2].addGestureRecognizer(gestureWikipedia)
		icons[3].addGestureRecognizer(gestureFacebook)
		icons[4].addGestureRecognizer(gestureTwitter)
		
		collectionView.delegate = self
		collectionView.dataSource = self
		addSubview(collectionView)
        collectionView.fillSuperview(padding: .zero)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	@objc private func handleGestureInstagram(_ sender: UITapGestureRecognizer) {
		self.handlerInstagram?()
	}
	
	@objc private func handleGestureTiktok(_ sender: UITapGestureRecognizer) {
		self.handlerTiktok?()
	}
	
	@objc private func handleGestureWikipedia(_ sender: UITapGestureRecognizer) {
		self.handlerWikipedia?()
	}
	
	@objc private func handleGestureFacebook(_ sender: UITapGestureRecognizer) {
		self.handlerFacebook?()
	}
	
	@objc private func handleGestureTwitter(_ sender: UITapGestureRecognizer) {
		self.handlerTwitter?()
	}
}

extension UserProfileIconsView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { icons.count }
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: IconsCell.self, indexPath: indexPath)
        if !dataSource[indexPath.item].urlSocialMedia.isNilOrEmpty {
            cell.imageView.image = iconsActive[indexPath.row].image
        } else {
            cell.imageView.image = icons[indexPath.row].image
        }
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 5)
		let size = CGSize(width: width, height: 32)
		return size
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			self.handlerInstagram?()
		case 1:
			self.handlerTiktok?()
		case 2:
			self.handlerWikipedia?()
		case 3:
			self.handlerFacebook?()
		case 4:
			self.handlerTwitter?()
		default:
			break
		}
	}
}

class IconsCell: UICollectionViewCell {
	
	var handler: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViewCell()
	}
	
	lazy var imageView: UIImageView = {
		let imageView: UIImageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureIcon))
		return imageView
	}()
	
	func setupViewCell(){
		
		addSubview(imageView)
		imageView.fillSuperview()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(isActive: Bool, type: String) {
		imageView.isUserInteractionEnabled = isActive
		switch (type) {
		case SocialMediaType.instagram.rawValue:
			let activeImage = UIImageView(image: UIImage(named: .get(.iconActiveInstagram))!)
			let nonActiveImage = UIImageView(image: UIImage(named: .get(.iconNonActiveInstagram))!)
			imageView = isActive == true ? activeImage : nonActiveImage
			
		case SocialMediaType.tiktok.rawValue:
			let activeImage = UIImageView(image: UIImage(named: .get(.iconActiveTiktok))!)
			let nonActiveImage = UIImageView(image: UIImage(named: .get(.iconNonActiveTiktok))!)
			imageView = isActive == true ? activeImage : nonActiveImage
				
		case SocialMediaType.wikipedia.rawValue:
			let activeImage = UIImageView(image: UIImage(named: .get(.iconActiveWikipedia))!)
			let nonActiveImage = UIImageView(image: UIImage(named: .get(.iconNonActiveWikipedia))!)
			imageView = isActive == true ? activeImage : nonActiveImage
			
		case SocialMediaType.facebook.rawValue:
			let activeImage = UIImageView(image: UIImage(named: .get(.iconNonActiveFacebook))!)
			let nonActiveImage = UIImageView(image: UIImage(named: .get(.iconNonActiveFacebook))!)
			imageView = isActive  == true ? activeImage : nonActiveImage
			
		case SocialMediaType.twitter.rawValue:
			let activeImage = UIImageView(image: UIImage(named: .get(.iconNonActiveTwitter))!)
			let nonActiveImage = UIImageView(image: UIImage(named: .get(.iconNonActiveTwitter))!)
			imageView = isActive  == true ? activeImage : nonActiveImage
		default:
			break
		}
	}
	
	@objc func handleGestureIcon() {
		self.handler?()
	}
}
