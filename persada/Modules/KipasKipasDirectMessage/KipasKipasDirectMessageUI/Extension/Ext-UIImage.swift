//
//  Ext-UIImage.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import UIKit

extension UIImage {
    static func set(_ name: String, identifier: String? = nil) -> UIImage? {
        let image = UIImage(named: name, in: SharedBundle.shared.bundle, with: nil)
        image?.accessibilityIdentifier = identifier ?? name
        return image
    }
    
    static func get(_ key: AssetEnum) -> UIImage? {
        return UIImage.set(key.rawValue)
    }
}
