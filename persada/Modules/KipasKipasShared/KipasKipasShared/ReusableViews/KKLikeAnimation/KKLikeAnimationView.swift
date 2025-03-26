//
//  KKLikeAnimationView.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 16/02/24.
//

import UIKit

class KKLikeAnimationView: UIView {
    
    lazy var likeImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.iconReactionLike
        image.alpha = 0.0
        return image
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComponent()
    }

    func setupComponent() {
        addSubview(likeImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        likeImageView.frame = .init(
            x: (frame.width / 2) - 50,
            y: (frame.height / 2) - 50,
            width: 100,
            height: 100
        )
    }
}

