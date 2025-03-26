//
//  ResellerValidatorVerifiedViewUI.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

final class ResellerValidatorVerifiedViewUI: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.bold, size: 14)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Kamu belum bisa menggunakan fitur ini"
        label.accessibilityIdentifier = "titleLabel-ResellerValidatorVerifiedViewUI"
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Maaf, untuk saat ini kamu belum bisa mengatur produk untuk dijual reseller. Akun kamu harus verified terlebih dahulu agar kamu bisa menggunakan fitur ini."
        label.accessibilityIdentifier = "subitleLabel-ResellerValidatorVerifiedViewUI"
        return label
    }()
    
    private lazy var iconProfileVerified: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: .get(.iconProfileVerified))
        image.layer.cornerRadius = 20
        image.backgroundColor = .clear
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        image.accessibilityIdentifier = "iconProfileVerified-ResellerValidatorVerifiedViewUI"
        return image
    }()
    
    lazy var okayButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.accessibilityIdentifier = "okayButton-ResellerValidatorVerifiedViewUI"
        return button
    }()
    
    
    lazy var termAndConditionButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Syarat & Ketentuan Reseller", for: .normal)
        button.setTitleColor(.contentGrey, for: .normal)
        button.backgroundColor = .whiteSnow
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.accessibilityIdentifier = "termAndConditionButton-ResellerValidatorVerifiedViewUI"
        return button
    }()
    
    private lazy var resellerStackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [okayButton, termAndConditionButton])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 8
        container.axis = .vertical
        container.distribution = .fillEqually
        container.alignment = .center
        container.accessibilityIdentifier = "resellerStackView-ResellerValidatorVerifiedViewUI"
        return container
    }()
    
    private lazy var containerMainView: UIView = {
        let containerView: UIView = UIView(frame: CGRect(x: frame.midX  - (300 / 2), y: frame.midY / 2, width: 300, height: 380))
        containerView.backgroundColor = .white
        containerView.addSubview(iconProfileVerified)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(resellerStackView)
        containerView.layer.cornerRadius = 16
        containerView.accessibilityIdentifier = "containerMainView-ResellerValidatorVerifiedViewUI"
        
        NSLayoutConstraint.activate([
            iconProfileVerified.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            iconProfileVerified.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconProfileVerified.widthAnchor.constraint(equalToConstant: 120),
            iconProfileVerified.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconProfileVerified.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -22)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -22)
        ])
        
        NSLayoutConstraint.activate([
            resellerStackView.topAnchor.constraint(equalTo: subtitleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            resellerStackView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            resellerStackView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resellerStackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            resellerStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return containerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = true
        addSubview(containerMainView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
