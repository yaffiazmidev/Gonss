//
//  ProfileShowcaseComingSoonView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/03/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class ProfileShowcaseComingSoonView: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: .get(.imageCart))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Segera Hadir!"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Persiapkan dirimu untuk pengalaman berbelanja yang luar biasa."
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = .grey
        label.textAlignment = .center
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([imageView, titleLabel, descLabel])
        
        imageView.anchors.top.equal(view.anchors.top)
        imageView.anchors.size.equal(.init(width: 76, height: 60))
        imageView.anchors.leading.equal(view.anchors.leading, constant: 60)
        imageView.anchors.trailing.equal(view.anchors.trailing, constant: -60)
        
        titleLabel.anchors.top.equal(imageView.anchors.bottom, constant: 20)
        titleLabel.anchors.leading.equal(view.anchors.leading)
        titleLabel.anchors.trailing.equal(view.anchors.trailing)
        
        descLabel.anchors.top.equal(titleLabel.anchors.bottom, constant: 4)
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

private extension ProfileShowcaseComingSoonView {
    func configUI() {
        backgroundColor = .white
        
        addSubview(containerView)
        
        containerView.anchors.leading.equal(anchors.leading, constant: 80)
        containerView.anchors.trailing.equal(anchors.trailing, constant: -80)
        containerView.anchors.top.equal(anchors.top, constant: 78)
    }
}
