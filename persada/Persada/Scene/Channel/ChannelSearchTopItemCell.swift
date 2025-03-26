//
//  NewChannelSearchTopItemCell.swift
//  KipasKipas
//
//  Created by movan on 03/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChannelSearchTopItemCell: UICollectionViewCell {
    
    var data: Feed? {
        didSet {
            guard let data = data else { return }
            //imageView.loadImage(at: data.post?.medias?.first?.thumbnail?.medium ?? "")
            imageView.loadImage(at: data.post?.medias?.first?.thumbnail?.medium ?? "", .w240, emptyImageName: "bg_tiktok")
            
            iconView.image = decideIcon(data)
            
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        
        addSubview(imageView)
        addSubview(iconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        iconView.frame = CGRect(x: frame.width - 20, y: 8, width: 12, height: 12)
    }
    
    private func setupStyle() {
        setCornerRadius = 8
        setBorderWidth = 1
        setBorderColor = .gainsboro
        clipsToBounds = true
    }
    
    private func decideIcon(_ data: Feed) -> UIImage? {
        if data.post?.product != nil {
            return UIImage(named: .get(.iconCornerShopping))
        }
        
        if data.post?.medias?.count ?? 0 > 1 {
            return UIImage(named: .get(.iconCornerStack))
        }
        
        if data.post?.medias?.first?.type == "video" {
            return UIImage(named: .get(.iconCornerVideo))
        }
        
        return nil
    }
}

