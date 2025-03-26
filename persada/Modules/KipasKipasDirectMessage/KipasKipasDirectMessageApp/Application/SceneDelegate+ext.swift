import UIKit

extension SceneDelegate {
    var hasNavigationController: Bool {
        return window?.topNavigationController != nil
    }
    
    func pushOnce(_ destinationViewController: UIViewController, animated: Bool = true) {
        guard let top = window?.topViewController, type(of: top) != type(of: destinationViewController) else {
            return
        }
        
        window?.topNavigationController?.pushViewController(destinationViewController, animated: animated)
    }
    
    func presentOnce(_ destinationViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = window?.topViewController, type(of: top) != type(of: destinationViewController) else {
            return
        }
        window?.topViewController?.present(destinationViewController, animated: animated, completion: completion)
    }
    
    func pushViewControllerWithPresentFallback(_ destinationViewController: UIViewController, animated: Bool = true) {
        if hasNavigationController {
            window?.topNavigationController?.pushViewController(destinationViewController, animated: animated)
        } else {
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .fullScreen
            window?.topViewController?.present(navigationController, animated: animated)
        }
    }
    
    func dismissControllerWithPopFallback(animated: Bool = true, completion: (() -> Void)? = nil) {
        if hasNavigationController {
            if window?.topNavigationController?.presentingViewController != nil {
                window?.topNavigationController?.dismiss(animated: animated, completion: completion)
            } else {
                window?.topNavigationController?.popViewController(animated: animated)
                completion?()
            }
        } else {
            window?.topViewController?.dismiss(animated: animated, completion: completion)
        }
    }
}

// MARK: UIWindow
extension UIWindow {
    
    var topNavigationController: UINavigationController?  {
        return topViewController?.navigationController
    }

    private class func topViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let top = topViewController(nav.visibleViewController)
            return top
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                let top = topViewController(selected)
                return top
            }
        }

        if let presented = base?.presentedViewController {
            let top = topViewController(presented)
            return top
        }
        return base
    }
    
    var topViewController: UIViewController? {
        return UIWindow.topViewController(rootViewController)
    }
    
    func switchRootViewController(viewController: UIViewController, withAnimation animation: CATransitionSubtype = .fromRight) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = animation
        
        layer.add(transition, forKey: kCATransition)
        rootViewController = viewController
    }
}

