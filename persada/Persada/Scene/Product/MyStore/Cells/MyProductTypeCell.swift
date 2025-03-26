//
//  MyProductTypeCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 08/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class MyProductTypeCell: UICollectionViewCell {
    var type: ProductType? {
        didSet {
            allButton.isActive = type == .all
            originalButton.isActive = type == .original
            resellerButton.isActive = type == .reseller
        }
    }
    var didButtonSelected: ((ProductType) -> Void)?
    
    lazy var allButton: MyProductTypeButton = {
        let type = ProductType.all
        let button = MyProductTypeButton()
        button.titleText = type.name
        button.titleColorActive = .white
        button.titleColorDeactive = .black
        button.backgroundColorActive = .primary
        button.backgroundColorDeactive = .whiteSmoke
        button.onTap { self.didSelect(type) }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var originalButton: MyProductTypeButton = {
        let type = ProductType.original
        let button = MyProductTypeButton()
        button.titleText = type.name
        button.titleColorActive = .white
        button.titleColorDeactive = .black
        button.backgroundColorActive = .primary
        button.backgroundColorDeactive = .whiteSmoke
        button.onTap { self.didSelect(type) }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var resellerButton: MyProductTypeButton = {
        let type = ProductType.reseller
        let button = MyProductTypeButton()
        button.titleText = type.name
        button.titleColorActive = .white
        button.titleColorDeactive = .black
        button.backgroundColorActive = .primary
        button.backgroundColorDeactive = .whiteSmoke
        button.onTap { self.didSelect(type) }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.addSubViews([allButton, originalButton, resellerButton])
        allButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        originalButton.anchor(top: view.topAnchor, left: allButton.rightAnchor, bottom: view.bottomAnchor, paddingLeft: 8)
        resellerButton.anchor(top: view.topAnchor, left: originalButton.rightAnchor, bottom: view.bottomAnchor, paddingLeft: 8)
        return view
    }()

    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(mainView)
        mainView.fillSuperview(padding: .init(horizontal: 12, vertical: 0))
    }
    
    private func didSelect(_ type: ProductType){
        self.didButtonSelected?(type)
    }
}
