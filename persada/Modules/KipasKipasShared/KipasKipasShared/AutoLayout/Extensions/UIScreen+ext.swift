import UIKit

public extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
}
