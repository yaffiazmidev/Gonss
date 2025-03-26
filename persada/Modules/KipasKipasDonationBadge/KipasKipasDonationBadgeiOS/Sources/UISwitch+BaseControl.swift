import UIKit

public typealias KKSwitchValueChange = (_ value: Bool) -> Void

open class BaseControl: UIControl {
    open var valueChange: KKSwitchValueChange?
    open var isOn: Bool = false
}

extension CGRect {
    var drawOnPath: CGPath {
        let bezierPath = UIBezierPath()
        
        let radius = self.maxX/5
        let center = CGPoint(x: self.midX, y: self.midY)
        
        let x1 = center.x + radius * cos(-45.degreesToRadians)
        let y1 = center.y + radius * sin(-45.degreesToRadians)
        
        let x2 = center.x + radius * cos(135.degreesToRadians)
        let y2 = center.y + radius * sin(135.degreesToRadians)
        
        let x3 = center.x + (radius + radius * 0.5) * cos(-175.degreesToRadians)
        let y3 = center.y + (radius + radius * 0.5) * sin(-175.degreesToRadians)
        
        bezierPath.move(to: CGPoint(x: x3, y: y3))
        bezierPath.addLine(to: CGPoint(x: x2, y: y2))
        
        bezierPath.addLine(to: CGPoint(x: x1, y: y1))
        
        return bezierPath.cgPath
    }
    
    var drawOffPath: CGPath {
        let bezierPath = UIBezierPath()
        
        let radius = self.maxX/5
        let center = CGPoint(x: self.midX, y: self.midY)
        
        let x1 = center.x + radius * cos(-45.degreesToRadians)
        let y1 = center.y + radius * sin(-45.degreesToRadians)
        
        let x2 = center.x + radius * cos(135.degreesToRadians)
        let y2 = center.y + radius * sin(135.degreesToRadians)
        
        let x3 = center.x + radius * cos(-135.degreesToRadians)
        let y3 = center.y + radius * sin(-135.degreesToRadians)
        
        let x4 = center.x + radius * cos(45.degreesToRadians)
        let y4 = center.y + radius * sin(45.degreesToRadians)
        
        bezierPath.move(to: CGPoint(x: x3, y: y3))
        bezierPath.addLine(to: CGPoint(x: x4, y: y4))
        
        bezierPath.move(to: CGPoint(x: x1, y: y1))
        bezierPath.addLine(to: CGPoint(x: x2, y: y2))
        
        return bezierPath.cgPath
    }
    
    var bubbleShapePath: CGPath {
        let bubblePath = UIBezierPath()
        let sR = (size.width - size.height)/4
        let lR = size.height/2
        
        let l1 = CGPoint(x: sR, y: lR - sR)
        let l2 = CGPoint(x: sR, y: lR + sR)
        
        let c1 = CGPoint(x: sR * 2 + lR, y: 0)
        let c2 = CGPoint(x: sR * 2 + lR, y: lR * 2)
        
        let r1 = CGPoint(x: sR * 3 + lR * 2, y: lR - sR)
        let r2 = CGPoint(x: sR * 3 + lR * 2, y: lR + sR)
        
        let o1 = CGPoint(x: (lR + sR * 2)/4, y: lR - sR)
        let o2 = CGPoint(x: (lR + sR * 2)/4, y: lR + sR)
        let o3 = CGPoint(x: (lR * 2 + sR * 4) - (lR + sR * 2)/4, y: lR - sR)
        let o4 = CGPoint(x: (lR * 2 + sR * 4) - (lR + sR * 2)/4, y: lR + sR)
        
        let cC = CGPoint(x: sR * 2 + lR, y: lR)
        
        bubblePath.move(to: l1)
        bubblePath.addQuadCurve(to: c1, controlPoint: o1)
        bubblePath.addArc(withCenter: cC, radius: lR, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi * 3/2, clockwise: true)
        bubblePath.addQuadCurve(to: r1, controlPoint: o3)
        bubblePath.addLine(to: r2)
        
        bubblePath.addQuadCurve(to: c2, controlPoint: o4)
        bubblePath.addQuadCurve(to: l2, controlPoint: o2)
        bubblePath.addLine(to: l1)
        bubblePath.close()
        
        return bubblePath.cgPath
    }
    
    var drawModeOnPath: CGPath {
        let radius = self.maxX/2
        let center = CGPoint(x: self.midX, y: self.midY)
        
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: center, radius: radius, startAngle: 301.degreesToRadians, endAngle: 149.degreesToRadians, clockwise: true)
        bezierPath.addArc(withCenter: center, radius: radius, startAngle: 149.degreesToRadians, endAngle: 301.degreesToRadians, clockwise: true)
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    var drawModeOffPath: CGPath {
        let radius: CGFloat = self.maxX/2
        
        let centerA = CGPoint(x: self.midX, y: self.midY)
        let offset = radius * 1.0/3.0
        let centerB = CGPoint(x: centerA.x - offset, y: centerA.y - offset)
        
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: centerA, radius: radius, startAngle: 301.degreesToRadians, endAngle: 149.degreesToRadians, clockwise: true)
        bezierPath.addArc(withCenter: centerB, radius: radius, startAngle: 121.degreesToRadians, endAngle: 329.degreesToRadians, clockwise: false)
        bezierPath.close()
        
        return bezierPath.cgPath
    }
}

public extension CALayer {
    var areAnimationsEnabled: Bool {
        get { delegate == nil }
        set { delegate = newValue ? nil : CALayerAnimationsDisablingDelegate.shared }
    }
    
    private class CALayerAnimationsDisablingDelegate: NSObject, CALayerDelegate {
        static let shared = CALayerAnimationsDisablingDelegate()
        private let null = NSNull()
        
        func action(for layer: CALayer, forKey event: String) -> CAAction? {
            self.null
        }
    }
    
    func bringToFront() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: UInt32(sLayer.sublayers?.count ?? 0))
    }
    
    func sendToBack() {
        guard let sLayer = superlayer else {
            return
        }
        removeFromSuperlayer()
        sLayer.insertSublayer(self, at: 0)
    }
    
    func animateGradientColors(from: [CGColor], to: [CGColor], duration: Double) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        self.add(animation, forKey: nil)
    }
    
    func strokeAnimation(duration: Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        self.add(animation, forKey: "line")
    }
    
    func rotateAnimation(angal: CGFloat, duration: Double, repeatAnimation: Bool = false) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = angal
        rotationAnimation.duration = duration
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.repeatCount = repeatAnimation ? .infinity : 0
        self.add(rotationAnimation, forKey: "rotation")
    }
    
    func removeRotationAnimation() {
        self.removeAnimation(forKey: "rotation")
    }
    
    func animateShape(path: CGPath, duration: Double) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.toValue = path
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        self.add(animation, forKey: nil)
    }
    
    func doMask(by imageMask: UIImage) {
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = CGRect(x: 0, y: 0, width: imageMask.size.width, height: imageMask.size.height)
        bounds = maskLayer.bounds
        maskLayer.contents = imageMask.cgImage
        maskLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        mask = maskLayer
    }
    
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            bounds.size,
            isOpaque,
            UIScreen.main.scale
        )
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
}
