//
//  OrderEmptyView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class OrderEmptyView: UIView{
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.imageCart))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Belum ada transaksi"
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .placeholder
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(imageView)
        addSubview(label)
        label.anchor(paddingLeft: 32, paddingRight: 32)
        label.centerXTo(centerXAnchor)
        label.centerYTo(centerYAnchor)
        imageView.anchor(bottom: label.topAnchor, paddingLeft: 32, paddingBottom: 20, paddingRight: 32, width: 78, height: 62)
        imageView.centerXTo(centerXAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
