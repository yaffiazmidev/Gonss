import UIKit

open class MaterialLoadingIndicator: KKLoadingView {

    fileprivate let drawableLayer = CAShapeLayer()
    fileprivate let checkmarkLayer = CAShapeLayer()
    
    override open var color: UIColor {
        didSet {
            drawableLayer.strokeColor = self.color.cgColor
        }
    }
    
    @IBInspectable open var lineWidth: CGFloat = 3 {
        didSet {
            drawableLayer.lineWidth = self.lineWidth
            self.updatePath()
        }
    }
    
    open override var bounds: CGRect {
        didSet {
            updateFrame()
            updatePath()
        }
    }
    
    public convenience init(radius: CGFloat = 18.0, color: UIColor = .gray) {
        self.init()
        self.radius = radius
        self.color = color
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
        updatePath()
    }
    
    override open func startAnimating() {
        if self.isAnimating {
            return
        }
        self.isAnimating = true
        self.isHidden = false
        // Size is unused here.
        setupAnimation(in: self.drawableLayer, size: .zero)
    }
    
    override open func stopAnimating() {
        self.drawableLayer.removeAllAnimations()
        self.drawableLayer.isHidden = true
    }
    
    fileprivate func setup() {
        self.isHidden = true
        self.layer.addSublayer(self.drawableLayer)
        self.drawableLayer.strokeColor = self.color.cgColor
        self.drawableLayer.lineWidth = self.lineWidth
        self.drawableLayer.fillColor = UIColor.clear.cgColor
        self.drawableLayer.lineJoin = CAShapeLayerLineJoin.round
        self.drawableLayer.strokeStart = 0.99
        self.drawableLayer.strokeEnd = 1
        updateFrame()
        updatePath()
    }
    
    fileprivate func updateFrame() {
        self.checkmarkLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        self.drawableLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
    }
    
    fileprivate func updatePath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius: CGFloat = self.radius - self.lineWidth
        
        self.drawableLayer.path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat(2 * Double.pi),
            clockwise: true
        ).cgPath
    }
    
    override open func setupAnimation(in layer: CALayer, size: CGSize) {
        layer.isHidden = false
        layer.removeAllAnimations()
        
        layoutIfNeeded()
        
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnim.fromValue = 0
        rotationAnim.duration = 4
        rotationAnim.toValue = 2 * Double.pi
        rotationAnim.repeatCount = Float.infinity
        rotationAnim.isRemovedOnCompletion = false
        
        let startHeadAnim = CABasicAnimation(keyPath: "strokeStart")
        startHeadAnim.beginTime = 0.1
        startHeadAnim.fromValue = 0
        startHeadAnim.toValue = 0.25
        startHeadAnim.duration = 1
        startHeadAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let startTailAnim = CABasicAnimation(keyPath: "strokeEnd")
        startTailAnim.beginTime = 0.1
        startTailAnim.fromValue = 0
        startTailAnim.toValue = 1
        startTailAnim.duration = 1
        startTailAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let endHeadAnim = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnim.beginTime = 1
        endHeadAnim.fromValue = 0.25
        endHeadAnim.toValue = 0.99
        endHeadAnim.duration = 0.5
        endHeadAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let endTailAnim = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnim.beginTime = 1
        endTailAnim.fromValue = 1
        endTailAnim.toValue = 1
        endTailAnim.duration = 0.5
        endTailAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let strokeAnimGroup = CAAnimationGroup()
        strokeAnimGroup.duration = 1.5
        strokeAnimGroup.animations = [startHeadAnim, startTailAnim, endHeadAnim, endTailAnim]
        strokeAnimGroup.repeatCount = Float.infinity
        strokeAnimGroup.isRemovedOnCompletion = false
        
        layer.add(rotationAnim, forKey: "rotation")
        layer.add(strokeAnimGroup, forKey: "stroke")
    }
    
    open override func finish(completion: @escaping () -> Void) {
        checkmarkLayer.lineWidth = self.lineWidth
        checkmarkLayer.strokeColor = self.color.cgColor
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.lineCap = .round
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: 4, y: 20))
        path.addLine(to: CGPoint(x: 14, y: 6))
        
        let boundingBox = path.cgPath.boundingBox
        let centeringTransform = CGAffineTransform(translationX: (bounds.width - boundingBox.width) / 2, y: 0)
        path.apply(centeringTransform)
        
        checkmarkLayer.path = path.cgPath
        
        self.layer.addSublayer(checkmarkLayer)
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = 0.5
        
        let haptic = UIImpactFeedbackGenerator(style: .heavy)
        
        checkmarkLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")
        haptic.impactOccurred()
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isAnimating = false
            self.checkmarkLayer.removeAllAnimations()
            self.checkmarkLayer.removeFromSuperlayer()
            self.removeFromSuperview()
            
            completion()
        }
    }
}

public final class MaterialLoadingIndicatorSimple: MaterialLoadingIndicator {
    public override func finish(completion: @escaping () -> Void) {
        self.isAnimating = false
        self.drawableLayer.removeAllAnimations()
        self.removeFromSuperview()
        
        completion()
    }
}
