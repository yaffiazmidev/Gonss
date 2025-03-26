import UIKit

public protocol KBFloatingToastIconAnimatable {
    func animate()
}

public class RotationableImageView: UIImageView, KBFloatingToastIconAnimatable {
    public func animate() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -Double.pi
        rotationAnimation.toValue = -Double.pi * 2
        rotationAnimation.duration = 1
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 1
        rotationAnimation.speed = 2
        
        layer.add(rotationAnimation, forKey: nil)
    }
}
