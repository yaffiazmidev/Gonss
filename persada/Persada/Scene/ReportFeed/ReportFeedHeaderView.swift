//
//  ReportFeedHeaderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReportFeedHeaderView: UIView {
    
    var item: String? {
        didSet {
            bg.loadImage(at: item ?? "")
        }
    }
    
    private let bg: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 32.5
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.textAlignment = .left
        lbl.text = "Mengapa anda ingin melaporkan postingan ini?"
        lbl.font = .Roboto(.bold, size: 18)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 106)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
