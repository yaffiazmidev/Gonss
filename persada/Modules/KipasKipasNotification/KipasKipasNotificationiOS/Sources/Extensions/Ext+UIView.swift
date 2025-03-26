//
//  Ext+UIView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit

extension UIView {
    func removeSubview(withIdentifier identifier: String) {
        for subview in subviews {
            if subview.accessibilityIdentifier == identifier {
                subview.removeFromSuperview()
                return // Assuming there is only one view with this identifier
            }
        }
    }
}
