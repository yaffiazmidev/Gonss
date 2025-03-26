import UIKit

private enum AssociatedKeys: String {
    var key: UnsafeRawPointer { return .init(bitPattern: rawValue.hashValue)! }
    case previousNavBarColor
}

public protocol NavigationAppearanceUpdatable {}

extension NavigationAppearanceUpdatable where Self: UIViewController {
    public var previousNavbarColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.previousNavBarColor.key) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.previousNavBarColor.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func updateNavigationBarColor(
        _ newColor: UIColor,
        updatableHandler: @escaping EmptyClosure
    ) {
        UIView.performWithoutAnimation {
            self.navigationController?.navigationBar.backgroundColor = newColor
            updatableHandler()
        }
    }
}

