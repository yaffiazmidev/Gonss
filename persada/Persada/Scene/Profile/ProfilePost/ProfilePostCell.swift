//
//  ProfilePostCell.swift
//  Persada
//
//  Created by Muhammad Noor on 17/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ProfilePostCell: UICollectionViewCell {
    
    // MARK: - Public Property
    
    var item: ProfilePostCellViewModel? {
        didSet {
					imageView.loadImage(at: item?.imageUserUrl ?? "")
            
            if item?.videoUserUrl == "" {
                imagePost.previewImageUrl = URL(string: item?.imagePostUrl ?? "")
                imagePost.videoUrl = nil
            } else {
                imagePost.videoUrl = URL(string: item?.videoUserUrl ?? "")
                imagePost.previewImageUrl = nil
            }

            nameLabel.text = item?.name
            likesLabel.text = "\(item?.likes ?? 0)"
            commentsLabel.text = "\(item?.comments ?? 0)"
            dateLabel.text = Date(timeIntervalSince1970: TimeInterval((item?.date ?? 1000)/1000 )).timeAgoDisplay()
            buttonFollow.isHidden = item?.isFollow ?? false
            postTextLabel.text = item?.title
        }
    }
    
    var delegate: (() -> Void)?
    
    let imageView : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var imagePost : AGVideoPlayerView = {
        let image = AGVideoPlayerView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.shouldAutoplay = true
        image.shouldAutoRepeat = true
        image.shouldSwitchToFullscreen = false
        image.showsCustomControls = false
        return image
    }()
    
    lazy var buttonFollow: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = false
        button.setTitleColor(UIColor.init(hexString: "#BC1C22"), for: .normal)
        button.backgroundColor = UIColor.init(hexString: "#FAFAFA")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textColor = .red
        button.setImage(#imageLiteral(resourceName: "Union").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitle("Follow", for: .normal)
        return button
    }()
    
    lazy var buttonReport : UIButton = {
        let button = UIButton(image: #imageLiteral(resourceName: "iconReport"))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let nameLabel = UILabel(text: "Name Label")
    let dateLabel = UILabel(text: "Friday at 11:11AM")
    let postTextLabel = UILabel(text: "Here is my post text")
    lazy var buttonLike = UIButton(image: #imageLiteral(resourceName: "iconLike"))
    lazy var buttonComment = UIButton(image: #imageLiteral(resourceName: "iconComment"))
    let likesLabel = UILabel(text: "120", textColor: .black)
    let commentsLabel = UILabel(text: "130", textColor: .black)
    
    let imageViewGrid : UIView = {
        let vw = UIView(frame: .zero)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = .clear
        return vw
    }()
    
    // MARK: - Public Method
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        imageViewGrid.addSubview(imagePost)
        imagePost.fillSuperviewSafeAreaLayoutGuide()
        
        stack(hstack(
            imageView.withHeight(40).withWidth(40), stack(nameLabel, dateLabel), buttonFollow.withHeight(40).withWidth(80),spacing: 8).padTop(12),
              imageViewGrid,
              hstack(buttonLike.withWidth(30).withHeight(30),likesLabel, buttonComment.withWidth(30).withHeight(30), commentsLabel, UIView(), buttonReport).padTop(4),
              postTextLabel,
              spacing: 8).withMargins(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleReport() {
        delegate?()
    }
}
