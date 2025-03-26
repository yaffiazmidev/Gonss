//
//  ChannelSearchHashtagItemCell.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChannelSearchHashtagItemCell: UICollectionViewCell {
    
    // MARK:- Public Property
    
    var item: Hashtag? {
        didSet {
            guard let item = item else { return }
            totalLabel.text = "\(item.totalResult ?? 0)"
            hashtagLabel.text = "#\(item.name ?? "")"
        }
    }
    
    // MARK:- Private Property
    
    var hashtagLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .secondary
        lbl.font = .Roboto(.medium, size: 16)
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private var totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .placeholder
        lbl.textAlignment = .right
        lbl.font = .Roboto(.medium, size: 16)
        lbl.numberOfLines = 1
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        contentView.addSubview(totalLabel)
        totalLabel.anchor(right: contentView.rightAnchor)
        totalLabel.centerYTo(contentView.centerYAnchor)
        
        contentView.addSubview(hashtagLabel)
        hashtagLabel.anchor(left: contentView.leftAnchor, right: totalLabel.leftAnchor)
        hashtagLabel.centerYTo(contentView.centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
