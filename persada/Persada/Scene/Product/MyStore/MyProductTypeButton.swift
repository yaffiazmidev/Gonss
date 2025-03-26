//
//  MyProductTypeButton.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 08/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

@IBDesignable
class MyProductTypeButton: UIButton {
    @IBInspectable var titleColorActive: UIColor?
    @IBInspectable var titleColorDeactive: UIColor?
    @IBInspectable var backgroundColorActive: UIColor?
    @IBInspectable var backgroundColorDeactive: UIColor?
    
    @IBInspectable var isActive: Bool = false{
        didSet {
            self.setTitleColor(isActive ? titleColorActive : titleColorDeactive,for: .normal)
            self.backgroundColor = isActive ? backgroundColorActive : backgroundColorDeactive
        }
    }
    
    @IBInspectable var titleText: String? {
        didSet { self.setTitle(titleText, for: .normal) }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.titleLabel?.font = .Roboto(.medium, size: 12)
        self.contentEdgeInsets = .init(horizontal: 16, vertical: 12)
    }
}
