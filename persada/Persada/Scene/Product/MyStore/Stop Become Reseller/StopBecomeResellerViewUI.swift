//
//  StopBecomeResellerViewUI.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class StopBecomeResellerViewUI: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Apakah kamu yakin?"
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Setelah berhenti jadi reseller, produk akan dihapus dari etalase milikimu."
        return label
    }()
    
    lazy var iconWarning: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: .get(.iconHighPriority))!
        image.tintColor = .systemRed
        image.layer.cornerRadius = 20
        image.backgroundColor = .clear
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    lazy var yesButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ya, Berhenti jadi Reseller", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }()

    lazy var noButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tidak, kembali ke Produk Detail", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.5)
        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return button
    }()
    
    lazy var resellerSstackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [yesButton, noButton])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 4
        container.axis = .vertical
        container.distribution = .fill
        container.alignment = .fill

        return container
    }()
    
    lazy var mainView: UIView = {
        let containerView: UIView = UIView(frame: CGRect(x: frame.midX  - (300 / 2), y: frame.midY / 2, width: 300, height: 360))
        containerView.backgroundColor = .white
        containerView.addSubview(iconWarning)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(resellerSstackView)
        containerView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            iconWarning.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            iconWarning.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconWarning.widthAnchor.constraint(equalToConstant: 90),
            iconWarning.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconWarning.safeAreaLayoutGuide.bottomAnchor, constant: 16),
        ])

        NSLayoutConstraint.activate([
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -22)
        ])
        
        NSLayoutConstraint.activate([
            resellerSstackView.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 10),
            resellerSstackView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            resellerSstackView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resellerSstackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        return containerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        backgroundColor = .clear
        isOpaque = false
        addSubview(mainView)
    }
}
