import UIKit

open class ContainerViewController: UIViewController {
    private var childViewController: UIViewController?
    
    public func transition(
        to viewController: UIViewController,
        ignoreSafeArea: Bool = true,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        removeChildViewController()
        add(viewController, ignoreSafeArea: ignoreSafeArea, animated: animated)
        childViewController = viewController
        
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            completion()
            self.view.layoutIfNeeded()
        }
    }
    
    public func removeChildViewController(
        animated: Bool = false,
        completion: @escaping () -> Void = {}
    ) { 
        guard let childViewController else { return }
        childViewController.removeFromParentView()
        self.childViewController = nil
        completion()
    }
}

public extension UIViewController {
    func add(
        _ childViewController: UIViewController,
        ignoreSafeArea: Bool = true,
        animated: Bool = true,
        sendViewToBackOf frontView: UIView? = nil,
        insets: UIEdgeInsets = .zero
    ) {
        
        childViewController.view.alpha = animated ? 0.0 : 1.0
        
        addChild(childViewController)
        
        if let frontView {
            view.insertSubview(childViewController.view, belowSubview: frontView)
        } else {
            view.addSubview(childViewController.view)
        }
        
        let anchoredView: LayoutItem = ignoreSafeArea ? view : view.safeAreaLayoutGuide
        let hasBottomInset = safeAreaInsets.bottom > 0
        
        // TODO: Should not use hardcoded value
        let topInset: CGFloat = ignoreSafeArea ? 0 : insets.top
        let bottomInset: CGFloat = !hasBottomInset && !ignoreSafeArea ? 20 : 0
        
        childViewController.view.anchors.top.pin(to: anchoredView, inset: topInset)
        childViewController.view.anchors.leading.pin(inset: insets.left)
        childViewController.view.anchors.trailing.pin(inset: insets.right)
        childViewController.view.anchors.bottom.pin(to: anchoredView, inset: bottomInset)
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                childViewController.view.alpha = 1.0
            })
        }
        
        childViewController.didMove(toParent: self)
    }
    
    func add(
        childViewController: UIViewController,
        targetView: UIView,
        sendViewToBack: Bool = false,
        animated: Bool = true
    ) {
        childViewController.view.alpha = animated ? 0.0 : 1.0
        
        addChild(childViewController)
        
        if sendViewToBack {
            targetView.insertSubview(childViewController.view, at: 0)
        } else {
            targetView.addSubview(childViewController.view)
        }
        
        childViewController.view.anchors.edges.pin()
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                childViewController.view.alpha = 1.0
            })
        }
        
        childViewController.didMove(toParent: self)
    }
    
    func removeFromParentView(animated: Bool = true) {
        willMove(toParent: nil)
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                self.view.removeFromSuperview()
            })
        } else {
            self.view.removeFromSuperview()
        }
        removeFromParent()
    }
}
