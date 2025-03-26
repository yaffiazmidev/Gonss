import Foundation
import UIKit

public class KKProgressHUD: UIVisualEffectView {
    
    private let dimension: CGFloat = 100.0
    private let textLabel = UILabel()
    private let indicator = UIActivityIndicatorView(style: .large)
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: UIBlurEffect(style: .dark))
        
        isHidden = true
        alpha = 0
        layer.cornerRadius = 10
        clipsToBounds = true
        
        configureIndicator()
        configureTextLabel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let w = indicator.frame.width
        let h = indicator.frame.height
        indicator.frame = CGRect(x: (bounds.width - w) / 2.0, y: 18.0, width: w, height: h)
        
        textLabel.sizeToFit()
        textLabel.frame = .init(
            x: 0,
            y: indicator.frame.maxY,
            width: bounds.width,
            height: bounds.height - 23.0 - indicator.frame.height
        )
    }
    
    public func show(in view: UIView) {
        removeFromSuperview()
        
        view.isUserInteractionEnabled = false
        view.addSubview(self)
        view.bringSubviewToFront(self)
    
        anchors.width.equal(dimension)
        anchors.height.equal(dimension)
        anchors.center.align()
        
        setNeedsLayout()
        layoutIfNeeded()
        
        indicator.startAnimating()
        
        animate(duration: 0.3, animatedProperties: {
            self.isHidden = false
            self.alpha = 1
        }, completion: {})
    }
    
    public func dismiss(after delay: TimeInterval = 0.3) {
        animate(duration: delay) {
            self.isHidden = true
            self.alpha = 0
            self.indicator.stopAnimating()
        } completion: {
            self.superview?.isUserInteractionEnabled = true
            self.removeFromSuperview()
        }
    }
}

private extension KKProgressHUD {
    func configureTextLabel() {
        textLabel.numberOfLines = 0
        textLabel.font = .roboto(.medium, size: 16)
        textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        textLabel.textAlignment = .center
        textLabel.text = "Loading..."
        
        contentView.addSubview(textLabel)
    }
    
    func configureIndicator() {
        indicator.color = .white
        contentView.addSubview(indicator)
    }
    
    func animate(
        duration: TimeInterval,
        animatedProperties: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        UIView.animate(withDuration: duration, animations: {
            animatedProperties()
        }) { _ in
            completion()
        }
    }
}
