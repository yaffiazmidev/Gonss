//
//  ChannelSearchTopDivider.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ChannelSearchTopDividerViewCell: UICollectionViewCell {
    
    lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(divider)
        divider.anchor(left: leftAnchor, right: rightAnchor, height: 1)
        divider.centerYTo(centerYAnchor)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}



