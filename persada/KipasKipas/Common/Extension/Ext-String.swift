//
//  Ext-String.swift
//  KipasKipas
//
//  Created by DENAZMI on 23/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

extension String {
    func attributedText(font: UIFont = .systemFont(ofSize: 12), textColor: UIColor = .black) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
}
