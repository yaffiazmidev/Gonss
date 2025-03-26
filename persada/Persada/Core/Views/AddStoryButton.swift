//
//  AddStoryButton.swift
//  KipasKipas
//
//  Created by kuh on 07/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class AddStoryButton: UIButton {
    
    let gradientLayer = CAGradientLayer()
    lazy var container = UIView()
    lazy var imageStory: UIImageView = {
        let image: UIImageView = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .whiteSnow
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.setBorderColor = .white
        image.setBorderWidth = 1.5
        return image
    }()
    lazy var iconPlusImage: UIImageView = {
        let image: UIImageView = UIImageView()
        image.image = UIImage(named: .get(.iconAddStory))
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.tintColor = .white
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.fillSuperview()
        setupImageStory()
        setupPlusIcon()
//        setUsernameOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        imageStory.image = image
    }

    private func setupImageStory() {
        container.addSubview(imageStory)
        imageStory.fillSuperview()
    }

    private func setupPlusIcon() {
        container.addSubview(iconPlusImage)
        iconPlusImage.anchor(
            bottom: container.bottomAnchor,
            right: container.rightAnchor,
            paddingBottom: -12,
            paddingRight: 8,
            width: 24,
            height: 24
        )
        iconPlusImage.layer.cornerRadius = 12
        iconPlusImage.layer.borderWidth = 2
        iconPlusImage.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK:: BUGFIX - Set Username Overlay
    
    func setUsernameOverlay() {
        let cTop    = UIColor.clear.cgColor
        let cBottom = UIColor.black.withAlphaComponent(0.35).cgColor
        
        gradientLayer.colors = [cTop, cBottom]
        gradientLayer.locations = [0.6, 1]
        gradientLayer.cornerRadius = 10
        gradientLayer.frame = self.bounds

        imageStory.layer.insertSublayer(gradientLayer, at:0)
    }
    
}
