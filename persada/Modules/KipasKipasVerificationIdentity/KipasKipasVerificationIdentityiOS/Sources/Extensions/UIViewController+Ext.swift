//
//  UIViewController+Ext.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 03/06/24.
//

import UIKit
import KipasKipasShared

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func presentAlert(config: CustomPopUpConfigureItem, completion: (() -> Void)? = nil) {
        let alert = CustomPopUpViewController(
            title: config.title,
            description: config.description,
            iconImage: config.iconImage,
            iconHeight: config.iconHeight,
            withOption: config.withOption,
            cancelBtnTitle: config.cancelButtonTitle,
            okBtnTitle: config.okButtonTitle,
            isHideIcon: config.isHideIcon,
            okBtnBgColor: config.okButtonBackgroundColor,
            actionStackAxis: config.actionStackAxis
        )
        alert.handleTapOKButton = completion
        alert.modalTransitionStyle = .crossDissolve
        alert.modalPresentationStyle = .overFullScreen
        present(alert, animated: false)
    }
    
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
