//
//  NewUserProfileItemCell.swift
//  Persada
//
//  Created by NOOR on 23/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import FeedCleeps

class NewUserProfileItemCell: UICollectionViewCell {
	
	var item: ContentProfilePost? {
		didSet {
            profileImage.loadImage(at: item?.post?.medias?.first?.thumbnail?.large ?? "", .w360)
		}
	}
	
	lazy var profileImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFill
		image.clipsToBounds = true
		return image
	}()
	
	lazy var viewFrame: UIView = {
		let vw = UIView()
		vw.translatesAutoresizingMaskIntoConstraints = false
		return vw
	}()
	
	lazy var iconImage : UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.contentMode = .scaleAspectFit
		image.clipsToBounds = true
//        image.isHidden = true
		return image
	}()
	
    var isIconShowed = false
    
    lazy var iconTotalViewImage: UIImageView = {
        let image = UIImage(systemName: "play.fill")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()
    
    lazy var totalViewLabel: UILabel = {
        let label = UILabel()
        label.font = .Roboto(.medium, size: 11)
        label.textColor = .white
        label.text = "2304923"
        return label
    }()
    
    lazy var totalViewStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconTotalViewImage, totalViewLabel])
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(viewFrame)
		viewFrame.fillSuperviewSafeAreaLayoutGuide()
		
		viewFrame.addSubview(profileImage)
		profileImage.fillSuperviewSafeAreaLayoutGuide()
		profileImage.addSubview(iconImage)
        profileImage.addSubview(totalViewStack)
        
        iconTotalViewImage.anchor(width: 6, height: 8)
        totalViewStack.anchor(left: profileImage.leftAnchor, bottom: profileImage.bottomAnchor, right: profileImage.rightAnchor, paddingLeft: 6, paddingBottom: 6, paddingRight: 6, height: 14)
		iconImage.anchor(top: profileImage.topAnchor, right: profileImage.rightAnchor, paddingTop: 10, paddingRight: 10, width: 12, height: 12)
	}
	
	func decideIcon(feed: Feed) {
        let post = feed.post
        let media = post?.medias?.first
        let containingProduct = post?.product != nil
        let isMultiple = post?.medias?.count ?? 0 > 1
        let isVideo = media?.type == "video"
        let isDonation = feed.typePost == "donation"
        let type: PostMediaType = isDonation ? .donation : containingProduct ? .product : isMultiple ? .multiple : isVideo ? .video : .image
        iconImage.image = type.icon
        let count = feed.totalView ?? 0
        let countFormatted = count.countFormat()
        setUpTotalView(totalView: countFormatted)
	}
    
    private func setUpTotalView(totalView: String) {
        totalViewLabel.text = totalView
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
