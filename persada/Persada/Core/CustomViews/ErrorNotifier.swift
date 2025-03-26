//
//  ErrorNotifier.swift
//  KipasKipas
//
//  Created by batm batmandiri on 10/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ErrorFormNotifierLabel: UIView {
    
    
    let imageView = UIImageView(image: UIImage(named: "iconInvalidInput"))
    let labelError = UILabel(text: "\(StringEnum.numberHasBeenUsed.rawValue)", font: .Roboto(.medium ,size: 12), textColor: .warning, textAlignment: .left, numberOfLines: 2)
    
    private lazy var errorNotifView: UIView = {
        let view: UIView = UIView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .warning
       
        view.addSubview(imageView)
        view.addSubview(labelError)
        labelError.anchor(top: view.topAnchor, left: imageView.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0)
        imageView.anchor(top: labelError.topAnchor, left: view.leftAnchor, bottom: labelError.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        view.isHidden = true
    
        return view
    }()
}
