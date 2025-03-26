//
//  UIAplication+Ext.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
