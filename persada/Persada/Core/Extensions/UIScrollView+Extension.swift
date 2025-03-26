//
//  UIScrollView+Extension.swift
//  KipasKipas
//
//  Created by koanba on 15/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func update(contentView: UIView, height: CGFloat) {
        var newSize = self.frame.size
        newSize.height = height
        self.contentSize = newSize
        contentView.frame.size = newSize
    }
    
}
