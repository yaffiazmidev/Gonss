import UIKit

public extension UIView {
    var safeAreaTop: CGFloat {
        let safeFrame = safeAreaLayoutGuide.layoutFrame
        return safeFrame.minY
    }
    
    var safeAreaBottom: CGFloat {
        safeAreaPadding.bottom
    }
    
    private var safeAreaPadding: UIEdgeInsets {
        return appWindow?.safeAreaInsets ?? .zero
    }
    
    var appWindow: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first
    }
    
    private class func topVC(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let top = topVC(nav.visibleViewController)
            return top
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                let top = topVC(selected)
                return top
            }
        }

        if let presented = base?.presentedViewController {
            let top = topVC(presented)
            return top
        }
        return base
    }
    
    var topMostVC: UIViewController? {
        return UIView.topVC(appWindow?.rootViewController)
    }
    
    var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return scene?.statusBarManager?.statusBarFrame ?? .zero
        } else {
            // Fallback on earlier versions
            return UIApplication.shared.statusBarFrame
        }
    }
}
