//
//  UIImage+Ext.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 02/06/24.
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

extension UIImage {
    // Convenience initializer for creating an image from a Base64 string
    convenience init?(base64String: String) {
        // Decode the Base64 string into Data
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil
        }
        // Initialize UIImage with the decoded Data
        self.init(data: imageData)
    }
}
