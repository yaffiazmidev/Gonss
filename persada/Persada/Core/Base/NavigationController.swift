//
//  NavigationController.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

extension UINavigationController {

    func push(_ controller: UIViewController, hideBottomBar: Bool = false, hideBackButtonTitle: Bool = true) {
        controller.hidesBottomBarWhenPushed = hideBottomBar
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
          interactivePopGestureRecognizer?.delegate = self
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: DefaultValues.string, style: .plain, target: nil, action: nil)
        pushController(controller, animated: true)
    }

    func presentFullScreen(
        _ controller: UIViewController,
        animated: Bool = true,
        transition: UIModalTransitionStyle = .coverVertical,
        isShowCloseButton: Bool = true
    ) {
        controller.modalTransitionStyle = transition
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: animated, completion: nil)
    }

    private func pushController(_ viewController: UIViewController, animated: Bool) {
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        pushViewController(viewController, animated: animated)
    }
}

//extension UINavigationController: UINavigationControllerDelegate {
//    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        interactivePopGestureRecognizer?.isEnabled = (responds(to: #selector(getter: interactivePopGestureRecognizer)) && viewControllers.count > 1)
//  }
//}

//extension UINavigationController: UIGestureRecognizerDelegate {}
