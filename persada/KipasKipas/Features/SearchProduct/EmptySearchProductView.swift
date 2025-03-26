//
//  EmptySearchProductView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class EmptySearchProductView: UIView {
    
    lazy var imageUser: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: .get(.iconEmptySearchProduct))!
        return image
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.backgroundColor = .primary
        label.textAlignment = .center
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var handleTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(imageUser)
        NSLayoutConstraint.activate([
            imageUser.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            imageUser.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageUser.heightAnchor.constraint(equalToConstant: 80),
            imageUser.widthAnchor.constraint(equalToConstant: 104),
        ])
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageUser.bottomAnchor, constant: 16),
            titleLabel.widthAnchor.constraint(equalToConstant: 250),
            titleLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            subtitleLabel.widthAnchor.constraint(equalToConstant: 250),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        subtitleLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTap?()
        }
    }
}

extension UICollectionView {
    func emptyView(isEmpty: Bool, title: String = "", subtitle: String = "", handleAction: (() -> Void)?) {
        let emptyView = EmptySearchProductView(frame: frame)
        emptyView.titleLabel.text = title
        emptyView.subtitleLabel.text = subtitle
        emptyView.handleTap = handleAction
        backgroundView = isEmpty ? emptyView : nil
    }
}

