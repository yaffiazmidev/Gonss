//
//  HashtagField.swift
//  KipasKipas
//
//  Created by Icon+ Gaenael on 04/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class HastagField: UIView {
    
    private let tagsField = WSTagsField()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView(){
        tagsField.backgroundColor = .white
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsField.spaceBetweenLines = 4.0
        tagsField.spaceBetweenTags = 8.0
        tagsField.font = UIFont.Roboto(.medium, size: 12)
        tagsField.tintColor = .gray
        tagsField.textColor = .white
        tagsField.selectedColor = .black
        tagsField.selectedTextColor = .white
        tagsField.placeholderColor = .lightGray
        tagsField.keyboardAppearance = .dark
        tagsField.acceptTagOption = .space
        tagsField.shouldTokenizeAfterResigningFirstResponder = true
        tagsField.textField.textColor = .black
        
        addSubview(tagsField)
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagsField.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            tagsField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            tagsField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            tagsField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
        
        layer.cornerRadius = 8
        layer.borderWidth  = 0.5
        layer.borderColor  = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        
        textFieldEvents()
    }
    
    private func textFieldEvents() {
        // Events
        tagsField.onDidAddTag = { field, tag in
            print("DidAddTag", tag.text)
        }
        tagsField.onDidRemoveTag = { field, tag in
            print("DidRemoveTag", tag.text)
        }
        tagsField.onDidChangeText = { _, text in
            print("DidChangeText")
        }
        tagsField.onDidChangeHeightTo = { _, height in
            print("HeightTo", height)
        }
    }
    
}
