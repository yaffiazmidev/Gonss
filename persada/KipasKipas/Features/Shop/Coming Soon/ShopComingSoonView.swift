//
//  ShopComingSoonView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/03/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class ShopComingSoonView: UIView {
    
    let circleSize: CGFloat = 200
    let blurSize: CGFloat = 400
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconShopComingSoon
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Segera Hadir!"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Persiapkan dirimu untuk pengalaman berbelanja yang luar biasa."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .grey
        label.textAlignment = .center
        return label
    }()
    
    lazy var circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primary.withAlphaComponent(0.3)
        view.clipsToBounds = true
        view.layer.cornerRadius = circleSize / 2
        
        return view
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = blurSize / 2
        view.alpha = 1
        
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([imageView, titleLabel, descLabel])
        
        imageView.anchors.top.equal(view.anchors.top)
        imageView.anchors.size.equal(.init(width: 185, height: 200))
        imageView.anchors.leading.equal(view.anchors.leading, constant: 8)
        imageView.anchors.trailing.equal(view.anchors.trailing, constant: -8)
        
        titleLabel.anchors.top.equal(imageView.anchors.bottom, constant: 20)
        titleLabel.anchors.leading.equal(view.anchors.leading)
        titleLabel.anchors.trailing.equal(view.anchors.trailing)
        
        descLabel.anchors.top.equal(titleLabel.anchors.bottom, constant: 8)
        descLabel.anchors.leading.equal(view.anchors.leading)
        descLabel.anchors.trailing.equal(view.anchors.trailing)
        descLabel.anchors.bottom.equal(view.anchors.bottom)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

private extension ShopComingSoonView {
    func configUI() {
        backgroundColor = .white
        
        addSubviews([containerView, circleView, blurView])
        
        containerView.anchors.leading.equal(anchors.leading, constant: 80)
        containerView.anchors.trailing.equal(anchors.trailing, constant: -80)
        containerView.anchors.centerY.equal(safeAreaLayoutGuide.anchors.centerY, constant: -80)
        
        
        circleView.anchors.size.equal(.init(width: circleSize, height: circleSize))
        circleView.anchors.centerX.equal(anchors.centerX)
        circleView.anchors.bottom.equal(safeAreaLayoutGuide.anchors.bottom, constant: circleSize / 2)
        
        blurView.anchors.size.equal(.init(width: blurSize, height: blurSize))
        blurView.anchors.centerX.equal(anchors.centerX)
        blurView.anchors.bottom.equal(safeAreaLayoutGuide.anchors.bottom, constant: blurSize / 2)
    }
}
