//
//  ProfileFilterCell.swift
//  Persada
//
//  Created by Muhammad Noor on 15/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case post
    case event
    
    var description: String {
        switch self {
            case .post: return "Post"
            case .event: return "Event"
        }
    }
}

class ProfileFilterCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var option: ProfileFilterOptions! {
        didSet { titleLabel.text = option.description }
    }
    
    let titleLabel: UILabel = {
			let label: UILabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .gray, textAlignment: .center, numberOfLines: 1)
        label.backgroundColor = .white
        return label
    }()
    
    
    let counterLabel: UIButton = {
        let button: UIButton = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.layer.backgroundColor = UIColor.primary.cgColor
        button.layer.cornerRadius = 6.5
			button.titleLabel?.font = .Roboto(.bold, size: 12)
        button.setTitle("0", for: .normal)
        button.isUserInteractionEnabled = false
        button.backgroundColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        return button
    }()
    
    
    private let underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .primary : .lightGray
            underlineView.backgroundColor = isSelected ? .primaryLowTint : .white
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        titleLabel.fillSuperview()
        addSubview(titleLabel)
        titleLabel.centerXToSuperview()
        titleLabel.centerYToSuperview()
        
        addSubview(underlineView)
        addSubview(counterLabel)
        
        counterLabel.anchor(left: titleLabel.rightAnchor, paddingLeft: 4)
        counterLabel.centerYToSuperview()
        underlineView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

