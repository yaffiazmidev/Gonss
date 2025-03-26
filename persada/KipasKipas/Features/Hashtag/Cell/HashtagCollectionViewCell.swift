//
//  HashtagCollectionViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class HashtagCollectionViewCell: UICollectionViewCell {
    
    lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var contentIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        
        addSubview(itemImageView)
        addSubview(contentIcon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        itemImageView.frame = bounds
        contentIcon.frame = CGRect(x: frame.width - 20, y: 8, width: 12, height: 12)
    }
    
    private func setupStyle() {
        setCornerRadius = 8
        setBorderWidth = 1
        setBorderColor = .gainsboro
        clipsToBounds = true
    }

}
