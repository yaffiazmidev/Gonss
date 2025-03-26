import UIKit

public protocol NavigationAppearance: UIGestureRecognizerDelegate {}

public extension NavigationAppearance where Self: UIViewController {
    
    func setupNavigationBar(
        title: String = "",
        color: UIColor = UIColor.white,
        tintColor: UIColor = UIColor.black,
        shadowColor: UIColor? = nil,
        isTransparent: Bool = false,
        prefersLargeTitles: Bool = false,
        backIndicator: UIImage? = UIImage.iconBack
    ) {
        if #available(iOS 13.0, *) {
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            appearance.shadowColor = shadowColor
            appearance.setBackIndicatorImage(backIndicator, transitionMaskImage: backIndicator)
            
            let attrs = [
                NSAttributedString.Key.foregroundColor: tintColor,
                NSAttributedString.Key.font: UIFont.roboto(.medium, size: 18)
            ]
            appearance.titleTextAttributes = attrs
            
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.isTranslucent = isTransparent
        }
        
        navigationItem.title = title
        navigationItem.backButtonTitle = ""
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.setPlainBarStyle(color: color, tintColor: tintColor, shadowColor: shadowColor)
    }
    
    func setupNavigationBarWithLargeTitle(
        title: String = "",
        color: UIColor = UIColor.white,
        tintColor: UIColor = UIColor.white,
        shadowColor: UIColor? = nil,
        isTransparent: Bool = false,
        prefersLargeTitles: Bool = false,
        largeFont: UIFont? = nil
    ) {
        if #available(iOS 13.0, *) {
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            appearance.shadowColor = shadowColor
            appearance.setBackIndicatorImage(.iconBack, transitionMaskImage: .iconBack)
          
            let attrLarge = [
                NSAttributedString.Key.foregroundColor: tintColor,
                NSAttributedString.Key.font: largeFont ?? UIFont.roboto(.bold, size: 38)
            ]
            appearance.largeTitleTextAttributes = attrLarge
            
            navigationItem.title = title
            self.navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.isTranslucent = isTransparent
        }
        
        navigationItem.backButtonTitle = ""
        navigationController?.setPlainBarStyle(color: color, tintColor: tintColor, shadowColor: shadowColor)
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
    
    fileprivate func setPlainBarStyle(
        color: UIColor = UIColor.white,
        tintColor: UIColor = UIColor.white,
        shadowColor: UIColor? = nil
    ) {
        setPlainBar(with: color, tintColor: tintColor, shadowColor: shadowColor)
    }
    
    fileprivate func setPlainBar(
        with color: UIColor = UIColor.white,
        tintColor: UIColor = UIColor.white,
        shadowColor: UIColor? = nil
    ) {
        if let shadowColor = shadowColor {
            self.navigationBar.addShadow(ofColor: shadowColor)
        } else {
            self.navigationBar.shadowImage = UIImage()
        }
        self.view.backgroundColor = color
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.backgroundColor = color
        self.navigationBar.barTintColor = color
        self.navigationBar.tintColor = tintColor
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: tintColor,
            NSAttributedString.Key.font: UIFont.roboto(.medium, size: 14)
        ]
        self.navigationBar.titleTextAttributes = attrs
    }
}

private extension UIView {
    func addShadow(
        ofColor color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0),
        radius: CGFloat = 3,
        offset: CGSize = .zero,
        opacity: Float = 0.5
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}

