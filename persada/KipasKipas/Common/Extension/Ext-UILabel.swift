//
//  Ext-UILabel.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

extension UILabel {
    
    func underline() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: self.text ?? "", attributes: underlineAttribute)
        attributedText =  underlineAttributedString
    }
    
    func strikethrough() {
        let strikethroughAttribute = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        let strikethroughAttributedString = NSAttributedString(string: self.text ?? "", attributes: strikethroughAttribute)
        attributedText =  strikethroughAttributedString
    }
}

