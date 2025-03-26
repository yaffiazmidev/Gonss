//
//  ResellerValidatorViewUI.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ResellerValidatorViewUI: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Kamu belum bisa menggunakan fitur ini"
        label.accessibilityIdentifier = "titleLabel-ResellerValidatorViewUI"
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Pastikan kamu memenuhi kriteria berikut :"
        label.accessibilityIdentifier = "subitleLabel-ResellerValidatorViewUI"
        return label
    }()
    
    private lazy var iconWarning: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: .get(.iconHighPriority))
        image.tintColor = .systemRed
        image.layer.cornerRadius = 20
        image.backgroundColor = .clear
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.accessibilityIdentifier = "iconWarning-ResellerValidatorViewUI"
        return image
    }()
    
    private lazy var followerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Memiliki 1.000 Follower"
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "followerLabel-ResellerValidatorViewUI"
        return label
    }()
    
    private lazy var totalPostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Memiliki minimal 1 postingan"
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "totalPostLabel-ResellerValidatorViewUI"
        return label
    }()
    
    private lazy var shopDisplayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sudah membuka etalase toko"
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "shopDisplayLabel-ResellerValidatorViewUI"
        return label
    }()
    
    private lazy var iconFollower: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 6, y: 0, width: 20, height: 20))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "xmark.circle.fill")
        image.tintColor = .systemGreen
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.contentMode = .center
        image.accessibilityIdentifier = "iconFollower-ResellerValidatorViewUI"
        return image
    }()
    
    private lazy var iconTotalPost: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 6, y: 0, width: 20, height: 20))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "xmark.circle.fill")
        image.tintColor = .systemGreen
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.contentMode = .center
        image.accessibilityIdentifier = "iconTotalPost-ResellerValidatorViewUI"
        return image
    }()
    
    private lazy var iconShopDisplay: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 6, y: 0, width: 20, height: 20) )
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "xmark.circle.fill")
        image.tintColor = .systemGreen
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.contentMode = .center
        image.accessibilityIdentifier = "iconShopDisplay-ResellerValidatorViewUI"
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
        button.accessibilityIdentifier = "okayButton-ResellerValidatorViewUI"
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
        button.accessibilityIdentifier = "termAndConditionButton-ResellerValidatorViewUI"
        return button
    }()
    
    private lazy var resellerStackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [okayButton, termAndConditionButton])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 8
        container.axis = .vertical
        container.distribution = .fillEqually
        container.alignment = .center
        container.accessibilityIdentifier = "resellerStackView-ResellerValidatorViewUI"
        return container
    }()
    
    private lazy var rulesFollowerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconFollower)
        view.addSubview(followerLabel)
        NSLayoutConstraint.activate([
            iconFollower.topAnchor.constraint(equalTo: view.topAnchor),
            iconFollower.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconFollower.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            followerLabel.topAnchor.constraint(equalTo: view.topAnchor),
            followerLabel.leadingAnchor.constraint(equalTo: iconFollower.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            followerLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            followerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.accessibilityIdentifier = "rulesFollowerView-ResellerValidatorViewUI"
        return view
    }()
    
    private lazy var rulesTotalPostView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconTotalPost)
        view.addSubview(totalPostLabel)
        NSLayoutConstraint.activate([
            iconTotalPost.topAnchor.constraint(equalTo: view.topAnchor),
            iconTotalPost.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconTotalPost.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            totalPostLabel.topAnchor.constraint(equalTo: view.topAnchor),
            totalPostLabel.leadingAnchor.constraint(equalTo: iconTotalPost.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            totalPostLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            totalPostLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.accessibilityIdentifier = "rulesTotalPostView-ResellerValidatorViewUI"
        return view
    }()
    
    private lazy var rulesShopDisplayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconShopDisplay)
        view.addSubview(shopDisplayLabel)
        NSLayoutConstraint.activate([
            iconShopDisplay.topAnchor.constraint(equalTo: view.topAnchor),
            iconShopDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconShopDisplay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            shopDisplayLabel.topAnchor.constraint(equalTo: view.topAnchor),
            shopDisplayLabel.leadingAnchor.constraint(equalTo: iconShopDisplay.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            shopDisplayLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shopDisplayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.accessibilityIdentifier = "rulesShopDisplayView-ResellerValidatorViewUI"
        return view
    }()
    
    private lazy var followerStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .darkGray
        
        spacer.setContentCompressionResistancePriority(UILayoutPriority(240), for: .horizontal)
        spacer.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        
        let container = UIStackView(arrangedSubviews: [ rulesFollowerView, spacer])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 20
        container.distribution = .fill
        container.alignment = .center
        container.accessibilityIdentifier = "followerStackView-ResellerValidatorViewUI"
        return container
    }()
    
    private lazy var totalPostStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .darkGray
        
        spacer.setContentCompressionResistancePriority(UILayoutPriority(240), for: .horizontal)
        spacer.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        
        let container = UIStackView(arrangedSubviews: [ rulesTotalPostView, spacer])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 20
        container.distribution = .fill
        container.alignment = .center
        container.accessibilityIdentifier = "totalPostStackView-ResellerValidatorViewUI"
        return container
    }()
    
    private lazy var shopDisplayStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .darkGray
        
        spacer.setContentCompressionResistancePriority(UILayoutPriority(240), for: .horizontal)
        spacer.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        
        let container = UIStackView(arrangedSubviews: [ rulesShopDisplayView, spacer])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 20
        container.distribution = .fill
        container.alignment = .center
        container.accessibilityIdentifier = "shopDisplayStackView-ResellerValidatorViewUI"
        return container
    }()
    
    private lazy var rulesStackView: UIStackView = {
        let container = UIStackView(arrangedSubviews: [followerStackView, totalPostStackView, shopDisplayStackView])
        container.translatesAutoresizingMaskIntoConstraints = false
        container.spacing = 2
        container.distribution = .fillEqually
        container.alignment = .leading
        container.axis = .vertical
        container.accessibilityIdentifier = "rulesStackView-ResellerValidatorViewUI"
        return container
    }()
    
    lazy var containerMainView: UIView = {
        let containerView: UIView = UIView(frame: CGRect(x: frame.midX  - (300 / 2), y: frame.midY / 2, width: 300, height: 380))
        containerView.backgroundColor = .white
        containerView.addSubview(iconWarning)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(rulesStackView)
        containerView.addSubview(resellerStackView)
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
            rulesStackView.topAnchor.constraint(equalTo: subtitleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 8),
            rulesStackView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            rulesStackView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -22),
            rulesStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            resellerStackView.topAnchor.constraint(equalTo: rulesStackView.safeAreaLayoutGuide.bottomAnchor, constant: 16),
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
        isOpaque = false
        addSubview(containerMainView)
        
        NSLayoutConstraint.activate([
            containerMainView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerMainView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerMainView.heightAnchor.constraint(equalToConstant: 400),
            containerMainView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(verifyFollower: Bool, verifyTotalPost: Bool, verifyShopDisplay: Bool) {
        if verifyFollower {
           iconFollower.image = UIImage(systemName: "checkmark.circle.fill")
           iconFollower.tintColor = .success
           followerLabel.textColor = .grey
        } else {
           iconFollower.image = UIImage(systemName: "xmark.circle.fill")
           iconFollower.tintColor = .systemRed
           followerLabel.textColor = .systemRed
        }
        
        if verifyTotalPost {
           iconTotalPost.image = UIImage(systemName: "checkmark.circle.fill")
           iconTotalPost.tintColor = .success
           totalPostLabel.textColor = .grey
        } else {
           iconTotalPost.image = UIImage(systemName: "xmark.circle.fill")
           iconTotalPost.tintColor = .systemRed
           totalPostLabel.textColor = .systemRed
        }
        
        if verifyShopDisplay {
           iconShopDisplay.image = UIImage(systemName: "checkmark.circle.fill")
           iconShopDisplay.tintColor = .success
           shopDisplayLabel.textColor = .grey
        } else {
           iconShopDisplay.image = UIImage(systemName: "xmark.circle.fill")
           iconShopDisplay.tintColor = .systemRed
           shopDisplayLabel.textColor = .systemRed
        }
        
    }
    
}
