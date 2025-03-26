//
//  Ext+UIViewController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit

extension UIViewController {
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
}
