//
//  Ext+UIView.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/12/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

extension UIView {
    func loadViewFromNib<T: UIView>() -> T {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! T
    }
}
