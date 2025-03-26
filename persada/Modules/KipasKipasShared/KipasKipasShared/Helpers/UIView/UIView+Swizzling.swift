import UIKit

extension UIView {
    private enum AssociatedKeys: String {
        var key: UnsafeRawPointer { return .init(bitPattern: rawValue.hashValue)! }
        case layoutSubviewsCallback
    }
    
    public var layoutSubviewsCallback: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, AssociatedKeys.layoutSubviewsCallback.key) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, AssociatedKeys.layoutSubviewsCallback.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc private func swizzled_layoutSubviews() {
        self.swizzled_layoutSubviews()
        layoutSubviewsCallback?()
    }

    public static func swizzleLayoutSubviews() {
        guard let originalMethod = class_getInstanceMethod(UIView.self, #selector(layoutSubviews)),
              let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_layoutSubviews)) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

