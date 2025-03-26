//
//  UIViewController+Ext.swift
//  KipasKipasVerificationIdentityApp
//
//  Created by DENAZMI on 13/06/24.
//

import UIKit

extension UIViewController {
    
    func push(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func popToViewController<T: UIViewController>(ofType type: T.Type, animated: Bool = true) {
        if let navigationController = self.navigationController {
            guard let vc = navigationController.viewControllers.lazy.filter({ $0 is T }).first else { return }
            navigationController.popToViewController(vc, animated: animated)
        }
    }
}
