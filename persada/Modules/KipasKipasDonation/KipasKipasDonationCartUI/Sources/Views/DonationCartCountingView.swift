//
//  DonationCartCountingView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

public class DonationCartCountingView: UIView {
    
    private var count = 0
    private var yellow = UIColor(hexString: "#FFA800", alpha: 1)
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = .roboto(.medium, size: 12)
        label.textColor = yellow
        
        return label
    }()
    
    private lazy var countView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = yellow.cgColor
        
        view.addSubview(countLabel)
        countLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 1, paddingLeft: 3, paddingBottom: 1, paddingRight: 3)
        
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = .iconDonationCartWhite
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = yellow
        clipsToBounds = true
        isHidden = true
        
        addSubviews([iconView, countView])
        iconView.anchor(paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 17, height: 17)
        iconView.centerYTo(centerYAnchor)
        iconView.centerXTo(centerXAnchor)
        countView.anchor(top: iconView.topAnchor, right: iconView.rightAnchor, paddingTop: -5, paddingRight: -5)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension DonationCartCountingView {
    func updateCount(with number: Int) {
        count = number
        countLabel.text = "\(number)"
        updateVisibility()
    }
    
    func updateVisibility() {
        isHidden = count <= 0
    }
    
    func withDefaultStyle() {
        backgroundColor = yellow
        iconView.image = .iconDonationCartWhite
        countView.backgroundColor = .white
        countView.layer.borderColor = yellow.cgColor
        countLabel.textColor = yellow
    }
    
    func withPlainStyle() {
        backgroundColor = .clear
        iconView.image = .iconDonationCartWhite?.withTintColor(yellow)
        countView.backgroundColor = yellow
        countView.layer.borderColor = UIColor.white.cgColor
        countLabel.textColor = .white
    }
}
