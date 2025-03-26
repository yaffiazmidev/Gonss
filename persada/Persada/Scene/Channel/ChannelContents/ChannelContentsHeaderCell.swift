//
//  ChannelContentsHeaderCell.swift
//  Persada
//
//  Created by Muhammad Noor on 14/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ChannelContentsHeaderCell: UICollectionViewCell {
	
	var handlerFollow: (() -> Void)?
    
    var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
		lbl.font = .Roboto(.regular, size: 12)
        lbl.textAlignment = .center
		lbl.textColor = .contentGrey
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var buttonFollow: BadgedButton = {
        let button = BadgedButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = false
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .primary
		button.titleLabel?.font = .Roboto(.medium, size: 12)
        button.setTitle("Follow", for: .normal)
		button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        stack(messageLabel,
              buttonFollow.withSize(CGSize(width: 80, height: 40)),
              spacing: 16,
              alignment: .center).withMargins(.allSides(12))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

	@objc func handleFollow() {
		self.handlerFollow?()
	}
}
