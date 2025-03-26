//
//  EmptyCourierView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 02/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class EmptyCourierView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .Roboto(.bold, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .get(.somethingWrong)
        label.textColor = .black
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 10)
        label.textColor = .grey
        label.numberOfLines = 0
        label.text = .get(.errorCourier)
        return label
    }()
    
    lazy var refreshButton: PrimaryButton = {
        let button = PrimaryButton(title: .get(.refresh), titleColor: .white, font: .Roboto(.regular, size: 12), backgroundColor: .primaryPink)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(refreshButton)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, height: 20)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor , right: rightAnchor, paddingTop: 8, height: 50)
        refreshButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingBottom: 30, height: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
