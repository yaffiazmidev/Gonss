//
//  FollowArtistCell.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class FollowArtistCell: UICollectionViewCell {
    
     // MARK:- Public Property
    
    var data: ContentArtist? {
        didSet {
            if let data = data, let isVerified = data.isVerified {
							imageView.loadImage(at: data.photo ?? "")
                nameLabel.text = data.name
                verifiedImg.isHidden = !isVerified
            }
        }
    }
    
    lazy var buttonFollow: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 16
        button.setTitle("Follow", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        return button
    }()
    
    private let verifiedImg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "iconVerified")
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var imageView : UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 30
        image.layer.masksToBounds = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.textColor = .lightGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let messageLabel: UILabel = {
        let lbl = UILabel(frame: .zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.textColor = .lightGray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override var isHighlighted: Bool {
        didSet {
            buttonFollow.backgroundColor = !isHighlighted ? .red : .init(hexString: "#EEEEEE")
            buttonFollow.setTitleColor(!isHighlighted ? .white : .red , for: .normal)
            buttonFollow.setTitle(!isHighlighted ? "Follow" : "Unfollow", for: .normal)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            buttonFollow.backgroundColor = !isSelected ? .red : .init(hexString: "#EEEEEE")
            buttonFollow.setTitleColor(!isSelected ? .white : .red , for: .normal)
            buttonFollow.setTitle(!isSelected ? "Follow" : "Unfollow", for: .normal)
        }
    }
    
    // MARK:- Public Method
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .init(hexString: "#FAFAFA")
        stack(imageView.withSize(.init(width: 60, height: 60)),
              stack(nameLabel, messageLabel, UIView(), buttonFollow.withSize(CGSize(width: 100, height: 35)), spacing: 6),
              spacing: 16,
              alignment: .center).withMargins(.allSides(20))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
