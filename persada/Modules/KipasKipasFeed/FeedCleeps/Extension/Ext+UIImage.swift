//
//  Ext+UIImage.swift
//  FeedCleeps
//
//  Created by DENAZMI on 04/10/23.
//

import UIKit

extension UIImageView {
    func set(_ name: String) {
        image = UIImage(named: name, in: SharedBundle.shared.bundle, with: nil)
    }
    
    func setImage(_ asset: AssetEnum) {
        image = UIImage(named: asset.rawValue, in: SharedBundle.shared.bundle, with: nil)
    }
}
