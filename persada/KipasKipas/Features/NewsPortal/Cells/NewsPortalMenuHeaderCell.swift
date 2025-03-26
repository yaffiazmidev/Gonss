//
//  NewsPortalMenuHeaderCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

enum NewsPortalMenuHeaderCellAction {
    case none
    case setup
    case save
}

protocol NewsPortalMenuHeaderCellDelegate: AnyObject {
    func didSetup()
    func didSave()
}

class NewsPortalMenuHeaderCell: UICollectionReusableView {
    
    weak var delegate: NewsPortalMenuHeaderCellDelegate?
    
    let actionIconSize: CGFloat = 14
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 14)
        label.textColor = .contentGrey
        label.textAlignment = .left
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var actionSetupView: UIStackView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: .get(.iconSettingGrey))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 11)
        label.textColor = .contentGrey
        label.text = "Atur Urutan"
        
        let view = UIStackView(arrangedSubviews: [image, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(horizontal: 8, vertical: 5)
        view.axis = .horizontal
        view.spacing = 4
        view.alignment = .center
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.grey.cgColor
        view.layer.borderWidth = 1
        
        image.anchor(width: actionIconSize, height: actionIconSize)
        
        return view
    }()
    
    private lazy var actionSaveView: UIStackView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: .get(.iconCheckCircleGrey))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 11)
        label.textColor = .contentGrey
        label.text = "Selesai"
        
        let view = UIStackView(arrangedSubviews: [image, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(horizontal: 8, vertical: 5)
        view.axis = .horizontal
        view.spacing = 4
        view.alignment = .center
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.grey.cgColor
        view.layer.borderWidth = 1
        
        image.anchor(width: actionIconSize, height: actionIconSize)
        
        return view
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, actionSetupView, actionSaveView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 4
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(mainView)
        mainView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, action: NewsPortalMenuHeaderCellAction) {
        titleLabel.text = title.uppercased()
        
        switch action {
        case .none:
            actionSetupView.isHidden = true
            actionSaveView.isHidden = true
        case .setup:
            actionSetupView.isHidden = false
            actionSaveView.isHidden = true
        case .save:
            actionSetupView.isHidden = true
            actionSaveView.isHidden = false
        }
        
//        actionSetupView.onTap { self.delegate?.didSetup() }
//        actionSaveView.onTap { self.delegate?.didSave() }
        actionSetupView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSetup()
        }
        actionSaveView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSave()
        }

    }
}
