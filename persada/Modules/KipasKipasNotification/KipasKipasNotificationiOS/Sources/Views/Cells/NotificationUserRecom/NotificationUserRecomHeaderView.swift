//
//  NotificationUserRecomHeaderView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit
import KipasKipasShared

class NotificationUserRecomHeaderView: UIView {
    
    let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    let viewAllStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 20, right: 8)
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    let recomContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return stackView
    }()
    
    private let viewAllDirectMessageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 4
        
        let viewAllLabel = UILabel()
        viewAllLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        viewAllLabel.text = "View all"
        viewAllLabel.textColor = UIColor(hexString: "4A4A4A")
        horizontalStackView.addArrangedSubview(viewAllLabel)
        
        let viewAllIcon = UIImageView()
        viewAllIcon.frame = .init(x: 0, y: 0, width: 9, height: 9)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        viewAllIcon.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfiguration)
        viewAllIcon.tintColor = UIColor(hexString: "#777777")
        viewAllIcon.contentMode = .scaleAspectFit
        horizontalStackView.addArrangedSubview(viewAllIcon)
        
        stackView.addArrangedSubview(horizontalStackView)
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Rekomendasi Akun"
        label.textColor = UIColor(hexString: "4A4A4A")
        return label
    }()
    
    private let infoIconImageView: UIImageView = {
        let view = UIImageView()
        view.frame = .init(x: 0, y: 0, width: 15, height: 15)
        view.image = .iconInfoOutlineGrey
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var handleOnTapViewAll: (() -> Void)?
    var handleOnTapInfo: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
        handleOnTapComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(viewAllStackView)
        viewAllStackView.addArrangedSubview(viewAllDirectMessageStackView)
        containerStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(recomContainerStackView)
        recomContainerStackView.addArrangedSubview(titleLabel)
        recomContainerStackView.addArrangedSubview(infoIconImageView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func handleOnTapComponents() {
        let onTapViewAll = UITapGestureRecognizer(target: self, action: #selector(handleTapViewAll))
        viewAllStackView.addGestureRecognizer(onTapViewAll)
        
        let onTapInfoGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapInfo))
        recomContainerStackView.isUserInteractionEnabled = true
        recomContainerStackView.addGestureRecognizer(onTapInfoGesture)
        
    }
    
    @objc private func handleTapViewAll() {
        handleOnTapViewAll?()
    }
    
    @objc private func handleTapInfo() {
        handleOnTapInfo?()
    }
}
