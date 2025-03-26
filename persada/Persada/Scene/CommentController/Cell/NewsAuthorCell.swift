//
//  DetailItemUsernameTableViewCell.swift
//  KipasKipas
//
//  Created by movan on 14/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import IGListKit

class NewsAuthorCell: UICollectionViewCell, ListBindable {
    
    var handler: (() -> Void)?
    
    let descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.backgroundColor = .white
        label.textColor = UIColor.black
        label.font = UIFont.Roboto(.regular, size: 16)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
        
        addSubview(descriptionLabel)

        descriptionLabel.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
    }
    
    func configure(_ name: String, _ isUsername: Bool) {
        descriptionLabel.text = name
        
        if isUsername {
            descriptionLabel.textColor = .secondary
            let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWhenTappedLabel))
            descriptionLabel.addGestureRecognizer(imageTapGesture)
        }
    }
    
    @objc private func handleWhenTappedLabel() {
        self.handler?()
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsAuthorViewModel else { return }
        
        let attributedStringEditor = "Penyunting".appendStringWithAtribute(string: "  \(viewModel.editor)", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)])

        let attributedStringPublisher = "\nPenulis".appendStringWithAtribute(string: "  \(viewModel.author)", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)])

        let desc = NSMutableAttributedString()
        desc.append(attributedStringEditor)
        desc.append(attributedStringPublisher)
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        desc.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, desc.length))
        
        self.descriptionLabel.font = .Roboto(.regular, size: 12)
        self.descriptionLabel.textColor = .black
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.attributedText = desc
        self.backgroundColor = .white
    }
}
