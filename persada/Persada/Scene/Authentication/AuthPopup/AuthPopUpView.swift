//
//  AuthPopUp.swift
//  KipasKipas
//
//  Created by batm batmandiri on 18/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol PopUpViewDelegate where Self: UIViewController {
    
    func whenLoginLabelCliked()
    func dismissCurrentPopUp()
}

final class AuthPopUpView: UIView {

    weak var delegate: PopUpViewDelegate?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.bold, size: 14)
        label.text = "\(StringEnum.masukAplikasi.rawValue)"
        label.textColor = .black
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.text = "\(StringEnum.loginFirst.rawValue)"
        label.numberOfLines = 2
        label.textColor = .grey
        label.textAlignment = .left
        return label
    }()
    
    lazy var spacer: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.bold, size: 12)
        label.text = "\(StringEnum.loginFirst.rawValue)"
        label.numberOfLines = 1
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 8
        return v
    }()
    
    lazy var backButton: UIButton = UIButton(title: .get(.back), titleColor: .placeholder, font: .Roboto(.medium, size: 12), backgroundColor: .clear, target: self, action: #selector(self.handleBack))
    
    lazy var loginButton: UIButton = UIButton(title: .get(.signIn), titleColor: .secondary, font: .Roboto(.bold, size: 12), backgroundColor: .clear, target: self, action: #selector(self.login))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.grey.withAlphaComponent(0.5)
        self.frame = UIScreen.main.bounds
        
        for item in [backButton, loginButton] {
            item.heightAnchor.constraint(equalToConstant: 56).isActive = true
            item.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        let actionStack = UIStackView(arrangedSubviews: [ spacer, backButton, loginButton])
        actionStack.alignment = .trailing
        actionStack.spacing = 16
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, actionStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 15
        
        self.addSubview(container)
        
        
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
        container.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        
        container.addSubview(stack)

        stack.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 24).isActive = true
        stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24).isActive = true
        stack.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -24).isActive = true
        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleBack() {
        delegate?.dismissCurrentPopUp()
    }
    
    @objc private func login() {
        delegate?.whenLoginLabelCliked()
    }
}
