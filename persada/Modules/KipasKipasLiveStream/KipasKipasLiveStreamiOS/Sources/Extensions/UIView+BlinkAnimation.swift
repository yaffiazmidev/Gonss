import UIKit

extension UIView {
    @MainActor func blink() {
        let blinkAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        blinkAnimation.fromValue = 0.2
        blinkAnimation.toValue = 1.0
        blinkAnimation.duration = 1
        blinkAnimation.repeatCount = .infinity
        blinkAnimation.autoreverses = true
        
        layer.add(blinkAnimation, forKey: #keyPath(CALayer.opacity))
    }
}
