//
//  NewsPortalMenuBackgroundCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class NewsPortalMenuBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondary.withAlphaComponent(0.08)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
