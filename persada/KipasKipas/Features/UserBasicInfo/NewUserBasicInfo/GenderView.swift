//
//  GenderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 29/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class GenderView: UIView {
    
    lazy var personLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "person-label"
        return label
    }()

    lazy var personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "person-image"
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return imageView
    }()

    lazy var personView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.setCornerRadius = 8
        vw.clipsToBounds = true
        vw.layer.cornerCurve = .circular
        
        vw.addSubview(personLabel)
        vw.addSubview(personImageView)
        
        personImageView.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
        personImageView.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
        
        personLabel.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 10).isActive = true
        personLabel.trailingAnchor.constraint(equalTo: vw.trailingAnchor, constant: -10).isActive = true
        personLabel.topAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: 8).isActive = true
        personLabel.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
        vw.accessibilityIdentifier = "person-view"
        return vw
    }()
    
    func setup(imageIcon: UIImage, title: String) {
        personLabel.text = title
        personImageView.image = imageIcon
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteSmoke
        addSubview(personView)
        personView.fillSuperviewSafeAreaLayoutGuide()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UnknownGenderView: UIView {
    
    lazy var unknownPersonLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .center, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "unknown-person-label"
        return label
    }()

    lazy var unknownPersonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "unknown-person-image"
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return imageView
    }()

    lazy var unknownPersonView: UIView = {
        let vw = UIView()
        vw.setCornerRadius = 8
        vw.clipsToBounds = true
        vw.layer.cornerCurve = .circular
        vw.translatesAutoresizingMaskIntoConstraints = false
        
        vw.addSubview(unknownPersonLabel)
        vw.addSubview(unknownPersonImageView)
        
        unknownPersonImageView.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
        unknownPersonImageView.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
        
        unknownPersonLabel.leadingAnchor.constraint(equalTo: vw.leadingAnchor, constant: 10).isActive = true
        unknownPersonLabel.trailingAnchor.constraint(equalTo: vw.trailingAnchor, constant: -10).isActive = true
        unknownPersonLabel.topAnchor.constraint(equalTo: unknownPersonImageView.bottomAnchor, constant: 8).isActive = true
        unknownPersonLabel.centerXAnchor.constraint(equalTo: vw.centerXAnchor).isActive = true
        vw.accessibilityIdentifier = "unknown-person-view"
        return vw
    }()
    
    func setup(imageIcon: UIImage, title: String) {
        unknownPersonLabel.text = title
        unknownPersonImageView.image = imageIcon
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteSmoke
        addSubview(unknownPersonView)
        unknownPersonView.fillSuperviewSafeAreaLayoutGuide()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GendersView: UIView {
    
    var handleClick: ((_ type: GenderType) -> Void)?
    
    lazy var personGuyView: GenderView = {
        let view = GenderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
        view.setup(imageIcon: UIImage(named: .get(.iconPersonGuy))!, title: .get(.pria))
        view.accessibilityIdentifier = "person-guy-view"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleClickMale))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    lazy var personGirlView: GenderView = {
        let view = GenderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
        view.setup(imageIcon: UIImage(named: .get(.iconPersonGirl))!, title: .get(.wanita))
        view.accessibilityIdentifier = "person-girl-view"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleClickFemale))
        view.addGestureRecognizer(gesture)
        return view
    }()

    lazy var personGenderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [personGuyView, personGirlView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.accessibilityIdentifier = "person-gender-stack"
        return stack
    }()
    
    lazy var personUnknownView: UnknownGenderView = {
        let view = UnknownGenderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
        view.setup(imageIcon: UIImage(named: .get(.iconPersonUnknown))!, title: .get(.noGender))
        view.accessibilityIdentifier = "person-gender-unknown"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleClickUnkown  ))
        view.addGestureRecognizer(gesture)
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return view
    }()
    
    let titleLabel = UILabel(text: .get(.imPerson), font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 1)
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [personGenderStack, personUnknownView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 24
        stack.accessibilityIdentifier =  "main-stack-gender"
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(mainStack)
        
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, height: 20)
        mainStack.anchor(top: titleLabel.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func handleClickMale() {
        handleClick?(.male)
    }
    
    @objc
    func handleClickFemale() {
        handleClick?(.female)
    }
    
    @objc
    func handleClickUnkown() {
        handleClick?(.unknown)
    }
}

enum GenderType: String {
    case male
    case female
    case unknown
}
