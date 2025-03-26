import UIKit

extension UINavigationController {
    public func setNavBarBorder(
        with color: UIColor,
        thickness: CGFloat = 1
    ) {
        navigationBar.layer.addBorder(
            edge: .bottom,
            color: color,
            thickness: thickness
        )
    }
    
    public func removeNavBarBorder() {
        navigationBar.layer.removeBorder(edge: .bottom)
    }
}
