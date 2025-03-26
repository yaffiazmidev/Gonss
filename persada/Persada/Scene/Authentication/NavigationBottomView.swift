//
//  NavigationBottomView.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class NavigationBottomView: UIView {
    
    lazy var backButton: UIButton = {
        let button = UIButton(title: "Back", titleColor: .lightGray, font: .boldSystemFont(ofSize: 14), backgroundColor: .clear, target: self, action: #selector(handleWhenTappedBackButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(title: "Next", titleColor: .red, font: .boldSystemFont(ofSize: 14), backgroundColor: .clear, target: self, action: #selector(handleWhenTappedNextButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var backClosure: (() -> Void)?
    var nextClosure: (() -> Void)?
    
    override func draw(_ rect: CGRect) {
        
        addSubview(backButton)
        addSubview(nextButton)
        
        backButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 50, height: 0)
        
        nextButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 50, height: 0)
    }
    
    @objc private func handleWhenTappedNextButton() {
        nextClosure?()
    }
    
    @objc private func handleWhenTappedBackButton() {
        backClosure?()
    }

}
