import UIKit

public final class PanNavigationViewController: UINavigationController, PanModalPresentable {
    
    public override init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [rootViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public override func popViewController(animated: Bool) -> UIViewController? {
        super.popViewController(animated: true)
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        return viewControllers.last
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        super.popToRootViewController(animated: animated)
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
        return viewControllers
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }

    // MARK: - Pan Modal Presentable
    private var presentable: PanModalPresentable? {
        guard let presentable = viewControllers.last as? PanModalPresentable else {
            return nil
        }
        return presentable
    }
    
    public var panScrollable: UIScrollView? {
        return presentable?.panScrollable
    }

    public var panModalBackgroundColor: UIColor {
        return presentable?.panModalBackgroundColor ?? .water
    }
    
    public var longFormHeight: PanModalHeight {
        return presentable?.longFormHeight ?? .maxHeight
    }

    public var shortFormHeight: PanModalHeight {
        return presentable?.shortFormHeight ?? .maxHeight
    }
    
    public var anchorModalToLongForm: Bool {
        return presentable?.anchorModalToLongForm ?? true
    }
    
    public var allowsExtendedPanScrolling: Bool {
        return presentable?.allowsExtendedPanScrolling ?? false
    }
    
    public var topOffset: CGFloat {
        return presentable?.topOffset ?? 0
    }
    
    public var allowsTapToDismiss: Bool {
        return presentable?.allowsTapToDismiss ?? true
    }
    
    public var allowsDragToDismiss: Bool {
        return presentable?.allowsDragToDismiss ?? false
    }
    
    public func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return presentable?.shouldRespond(to: panModalGestureRecognizer) ?? true
    }
    
    public func panModalWillDismiss() {
        presentable?.panModalWillDismiss()
    }
    
    public var cornerRadius: CGFloat {
        return presentable?.cornerRadius ?? 8.0
    }
    
    public func willTransition(to state: PanModalPresentationController.PresentationState) {
        panModalSetNeedsLayoutUpdate()
    }
}
