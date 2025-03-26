import UIKit

public protocol BadgeContainer: AnyObject {
    var badgeView: UIView? { get set }
    var badgeLabel: UILabel? { get set }
    
    func showBadge(text: String?)
    func hideBadge()
}

public extension BadgeContainer where Self: UIView {
    func showBadge(text: String?) {
        if badgeView != nil {
            if badgeView?.isHidden == false {
                badgeLabel?.text = text
                setNeedsLayout()
                layoutIfNeeded()
                return
            }
        } else {
            badgeView = UIView()
        }
        
        guard let badgeView = badgeView else {
            return
        }
        
        badgeView.backgroundColor = .watermelon
        addSubview(badgeView)

        if let text = text {
            if badgeLabel == nil {
                badgeLabel = UILabel()
            }
            
            guard let badgeLabel = badgeLabel else {
                return
            }
            
            badgeLabel.textAlignment = .center
            badgeLabel.text = text
            badgeLabel.textColor = .white
            badgeLabel.font = .roboto(.medium, size: 9)
            
            badgeView.addSubview(badgeLabel)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func hideBadge() {
        badgeView?.removeFromSuperview()
        badgeView = nil
        badgeLabel = nil
    }
}

public final class BadgeButton: UIButton, BadgeContainer {
    public var badgeView: UIView?
    public var badgeLabel: UILabel?
    
    private let verticalPadding: CGFloat = 2
    private let horizontalPadding: CGFloat = 3
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let badgeView, let badgeLabel else { return }
        
        let textSize = UILabel.textSize(font: .roboto(.medium, size: 9), text: badgeLabel.text ?? "")
      
        badgeView.frame = .init(
            x: bounds.midX + (horizontalPadding * 2),
            y: bounds.minY,
            width: textSize.width + (horizontalPadding * 2),
            height: textSize.height + (verticalPadding * 2)
        )
        
        let textCount = badgeLabel.text?.count ?? 0
        
        if textCount < 3 {
            badgeView.layer.cornerRadius = (textSize.width + (textCount < 2 ? (horizontalPadding * 2) : horizontalPadding)) / 2
        } else {
            badgeView.layer.cornerRadius = textSize.width / 2
        }
        
        badgeLabel.frame.size.width = textSize.width + (horizontalPadding * 2)
        badgeLabel.frame.size.height = textSize.height + (verticalPadding * 2)
        
        badgeLabel.center = .init(
            x: badgeView.frame.width / 2,
            y: badgeView.frame.height / 2
        )
    }
}

private extension UILabel {
    class func textSize(font: UIFont, text: String) -> (width: CGFloat, height: CGFloat) {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return (ceil(labelSize.width), ceil(labelSize.height))
    }
}

