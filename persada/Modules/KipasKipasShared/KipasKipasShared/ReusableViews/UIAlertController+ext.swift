import UIKit

public extension UIAlertController {
    func setTitleFont(_ font: UIFont?) {
        guard let title = title else { return }
        
        let attributeString = NSMutableAttributedString(string: title)
        let range = NSRange(location: 0, length: attributeString.length)
        
        if let font {
            attributeString.addAttributes(
                [NSAttributedString.Key.font: font],
                range: range
            )
        }
        setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setMessageFont(_ font: UIFont?) {
        guard let message = message else { return }
        
        let attributeString = NSMutableAttributedString(string: message)
        let range = NSRange(location: 0, length: attributeString.length)
        
        if let font {
            attributeString.addAttributes(
                [NSAttributedString.Key.font: font],
                range: range
            )
        }
        setValue(attributeString, forKey: "attributedMessage")
    }
    
    func setBackgroundColor(color: UIColor) {
        if let bgView = view.subviews.first,
           let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
}

public extension UIAlertAction {
    var titleTextColor: UIColor? {
        get { return self.value(forKey: "titleTextColor") as? UIColor }
        set { self.setValue(newValue, forKey: "titleTextColor") }
    }
}
