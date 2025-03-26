//
//  ChannelSearchTopFooterView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ChannelSearchTopFooterView: UICollectionReusableView {
    lazy var label: UILabel = {
        let label: UILabel = UILabel()
        label.adjustsFontForContentSizeCategory = false
        label.font = .Roboto(.medium, size: 16)
        label.textColor = .secondary
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 22, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
