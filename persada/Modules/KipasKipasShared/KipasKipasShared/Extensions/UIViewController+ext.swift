import UIKit

public enum tipMsgPosition : Int{
    case top = 1
    case center = 2
    case bottom = 3
     
}

public extension UIViewController {
    var safeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
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
    
    var appWindow: UIWindow? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first
    }
    
    func addBottomSafeAreaPaddingView(height: CGFloat = 0, color: UIColor = .white) {
        let paddingView = UIView()
        paddingView.backgroundColor = color
        
        let hasBottomInset = safeAreaInsets.bottom > 0
        
        view.addSubview(paddingView)
        paddingView.anchors.width.equal(view.anchors.width)
        paddingView.anchors.height.equal(hasBottomInset ? safeAreaInsets.bottom : height)
        paddingView.anchors.bottom.pin()
    }
    
    @discardableResult
    func wrapWithBottomSafeAreaPaddingView(
        _ wrappedView: UIView,
        height: CGFloat = 0,
        color: UIColor = .white
    ) -> NSLayoutConstraint {
        let paddingView = UIView()
        paddingView.backgroundColor = color
        
        let hasBottomInset = safeAreaInsets.bottom > 0
        
        view.addSubview(paddingView)
        paddingView.anchors.width.equal(view.anchors.width)
        paddingView.anchors.height.equal(hasBottomInset ? safeAreaInsets.bottom : height)
        paddingView.anchors.bottom.pin()
        
        view.addSubview(wrappedView)
        return wrappedView.anchors.bottom.spacing(0, to: paddingView.anchors.top)
    }
    
    func showTipsMsg(_ msg:String, position:tipMsgPosition = .top){
        let blackView = UIView()
        blackView.backgroundColor = .black
        self.view.addSubview(blackView)
        blackView.anchors.centerX.align()
        switch position {
            case .top:
            blackView.anchors.top.pin(inset: 100)
            case .center:
            blackView.anchors.centerY.align()
            case .bottom:
            blackView.anchors.bottom.pin(inset: 60)
        }
        
        let toastLabel = UILabel()
        toastLabel.textAlignment = .center
        toastLabel.font = .roboto(.regular, size: 12)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = .black
        toastLabel.numberOfLines = 0
        
        toastLabel.text = msg
        blackView.addSubview(toastLabel)
        toastLabel.anchors.center.align()
        
        let maxTitleW = UIScreen.width * 0.9 - 24*2
        
        let titleOneSize = toastLabel.sizeThatFits(CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX))
        
        var labelTitleW  = titleOneSize.width
        var labelTitleH  = titleOneSize.height
        var radius = (labelTitleH + 10*2) / 2
        if labelTitleW > maxTitleW {
            labelTitleW = maxTitleW
            let titleMoreSize = toastLabel.sizeThatFits(CGSizeMake(labelTitleW, CGFLOAT_MAX))
            labelTitleW = titleMoreSize.width
            labelTitleH = titleMoreSize.height
            radius = 22
        }
      
        toastLabel.anchors.width.equal(labelTitleW )
        toastLabel.anchors.height.equal(labelTitleH )
        
        blackView.anchors.width.equal(labelTitleW + 24*2)
        blackView.anchors.height.equal(labelTitleH + 10*2)
        blackView.layer.cornerRadius = radius
        
        blackView.layer.masksToBounds = true
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseOut, animations: {
            blackView.alpha = 0.0
        }, completion: {(isCompleted) in
            blackView.removeFromSuperview()
        })
    }
    
    func showToast(
        with message: String,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7),
        isOnTopScreen: Bool = false,
        textColor: UIColor = UIColor.white,
        duration: Double? = 2.5,
        verticalSpace: CGFloat = 16,
        cornerRadius: CGFloat = 4,
        completion: (() -> Void)? = nil
    ) {
        
        var toastView: UIView? = UIView()
        toastView!.backgroundColor = backgroundColor
        toastView!.accessibilityIdentifier = "TOAST_VIEW_IDENTIFIER"
        toastView!.alpha = 0
        view.addSubview(toastView!)
        
        let space: CGFloat = verticalSpace
        
        toastView!.anchors.centerX.align()
        toastView!.anchors.trailing.lessThanOrEqual(view.anchors.trailing, constant: 16)
        toastView!.anchors.leading.greaterThanOrEqual(view.anchors.leading, constant: 16)
        
        if isOnTopScreen {
            toastView!.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top, constant: space)
        } else {
            toastView!.anchors.bottom.equal(view.safeAreaLayoutGuide.anchors.bottom, constant: -space)
        }
        
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .center
        label.text = message
        label.numberOfLines = 0
        label.font = .roboto(.regular, size: 11)
        toastView!.addSubview(label)
        
        label.anchors.leading.pin(inset: 24)
        label.anchors.top.pin(inset: 10)
        label.anchors.trailing.pin(inset: 24)
        label.anchors.bottom.pin(inset: 10)
       
        toastView!.layoutIfNeeded()
        toastView!.layer.cornerRadius = cornerRadius
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, animations: {
                toastView!.alpha = 1
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + (duration ?? 2.5), execute: {
                    UIView.animate(withDuration: 0.33, animations: {
                        toastView!.alpha = 0
                    }, completion: { _ in
                        toastView!.removeFromSuperview()
                        toastView = nil
                        completion?()
                    })
                })
            })
        }
    }
    
    func showToast(
        with message: String,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7),
        isOnTopScreen: Bool = false,
        textColor: UIColor = UIColor.white,
        duration: Double? = 2.5,
        verticalSpace: CGFloat = 16,
        cornerRadius: CGFloat = 4,
        backgroundView: UIView,
        completion: (() -> Void)? = nil
    ) {
        
        var toastView: UIView? = UIView()
        toastView!.backgroundColor = backgroundColor
        toastView!.accessibilityIdentifier = "TOAST_VIEW_IDENTIFIER"
        toastView!.alpha = 0
        backgroundView.addSubview(toastView!)
        
        let space: CGFloat = verticalSpace
        
        toastView!.anchors.centerX.align()
        toastView!.anchors.trailing.lessThanOrEqual(backgroundView.anchors.trailing, constant: 16)
        toastView!.anchors.leading.greaterThanOrEqual(backgroundView.anchors.leading, constant: 16)
        
        if isOnTopScreen {
            toastView!.anchors.top.equal(backgroundView.safeAreaLayoutGuide.anchors.top, constant: space)
        } else {
            toastView!.anchors.bottom.equal(backgroundView.safeAreaLayoutGuide.anchors.bottom, constant: -space)
        }
        
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .center
        label.text = message + "  count = \(p)"
        p = p + 1
        label.numberOfLines = 0
        label.font = .roboto(.regular, size: 11)
        toastView!.addSubview(label)
        
        label.anchors.leading.pin(inset: 24)
        label.anchors.top.pin(inset: 10)
        label.anchors.trailing.pin(inset: 24)
        label.anchors.bottom.pin(inset: 10)
       
        toastView!.layoutIfNeeded()
        toastView!.layer.cornerRadius = cornerRadius
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.33, animations: {
                toastView!.alpha = 1
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + (duration ?? 2.5), execute: {
                    UIView.animate(withDuration: 0.33, animations: {
                        toastView!.alpha = 0
                    }, completion: { _ in
                        toastView!.removeFromSuperview()
                        toastView = nil
                        completion?()
                    })
                })
            })
        }
    }
    
    func showAlertController(
        title: String? = nil,
        titleFont: UIFont = .boldSystemFont(ofSize: 14),
        message: String? = nil,
        messageFont: UIFont = .systemFont(ofSize: 12),
        backgroundColor: UIColor? = nil,
        actions: [UIAlertAction] = []
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.setTitleFont(titleFont)
        alert.setMessageFont(messageFont)
       
        alert.overrideUserInterfaceStyle = .light
        
        for action in actions {
            alert.addAction(action)
        }
        
        if let backgroundColor = backgroundColor {
            alert.setBackgroundColor(color: backgroundColor)
        }
                
       present(alert, animated: false)
    }
    
    static func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl){
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}

extension UIViewController {
    public func configureDismissablePresentation(
        backIcon: UIImage? = .iconChevronLeft,
        tintColor: UIColor? = nil
    ) {
        let barButton = UIBarButtonItem(
            image: backIcon,
            style: .done,
            target: self,
            action: #selector(diss)
        )
        if let tintColor {
            barButton.tintColor = tintColor
        }
        navigationItem.setLeftBarButton(barButton, animated: false)
    }
    
    @objc private func diss() {
      forceDismiss()
    }
    
    public func forceDismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
        
        if let navigationController = navigationController,
           let presentation = navigationController.presentationController {
            navigationController.presentingViewController?.viewWillAppear(true)
            navigationController.presentingViewController?.viewDidAppear(true)
            presentation.presentedViewController.presentationAnimator = nil
        } else {
            guard let presentation = presentationController else { return }
            presentation.presentingViewController.viewWillAppear(true)
            presentation.presentingViewController.viewDidAppear(true)
            presentation.presentedViewController.presentationAnimator = nil
        }
    }
    
    public func presentWithSlideAnimation(_ destinationViewController: UIViewController, completion: (() -> Void)? = nil) {
        let interaction = InteractionConfiguration(
            presentingViewController: self,
            completionThreshold: 0.5,
            dragMode: .edge
        )
        let cover = CoverPresentation(
            directionShow: .right,
            directionDismiss: .right,
            size: PresentationSize(height: .fullscreen),
            alignment: PresentationAlignment(vertical: .bottom, horizontal: .center),
            interactionConfiguration: interaction
        )
        let animator = Animator(presentation: cover)
        animator.prepare(presentedViewController: destinationViewController)
        destinationViewController.presentationAnimator = animator
        
       present(destinationViewController, animated: true)
    }
}

public protocol AnimationDismissable {
    var presentationAnimator: Any? { get set }
}

private enum AssociatedKeys: String {
    var key: UnsafeRawPointer { return .init(bitPattern: rawValue.hashValue)! }
    case presentationAnimator
}

extension UIViewController: AnimationDismissable {
    public var presentationAnimator: Any? {
        get {
            guard let value = objc_getAssociatedObject(self, AssociatedKeys.presentationAnimator.key) else {
                return nil
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.presentationAnimator.key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

fileprivate var p = 0
public extension UIViewController {
    
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
        return UIViewController.topVC(appWindow?.rootViewController)
    }
    
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }
}
