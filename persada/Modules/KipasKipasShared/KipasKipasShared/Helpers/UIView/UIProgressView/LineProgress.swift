import UIKit

public enum LineProgressState {
    case determinate(percentage: CGFloat)
    case indeterminate
}

open class LineProgress: UIView {
    
    private let progressComponent = CAShapeLayer()
    
    private(set) var isAnimating = false
    open private(set) var state: LineProgressState = .indeterminate
    
    var animationDuration: TimeInterval = 1
    
    open var progressBarWidth: CGFloat = 2.0 {
        didSet {
            updateProgressBarWidth()
        }
    }
    
    open var progressBarColor: UIColor = .systemBlue {
        didSet {
            updateProgressBarColor()
        }
    }
    
    open var cornerRadius: CGFloat = 0 {
        didSet {
            updateCornerRadius()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        prepare()
        prepareLines()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepare()
        prepareLines()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        updateLineLayers()
    }
    
    private func prepare() {
        clipsToBounds = true
    }
    
    func prepareLines() {
        progressComponent.fillColor = progressBarColor.cgColor
        progressComponent.lineWidth = progressBarWidth
        progressComponent.strokeColor = progressBarColor.cgColor
        progressComponent.strokeStart = 0
        progressComponent.strokeEnd = 0
        layer.addSublayer(progressComponent)
    }
    
    private func updateLineLayers() {
        frame = CGRect(x: frame.minX, y: frame.minY, width: bounds.width, height: bounds.height)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: bounds.midY))
        linePath.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
 
        progressComponent.path = linePath.cgPath
        progressComponent.frame = bounds
    }
    
    private func updateProgressBarColor() {
        progressComponent.fillColor = progressBarColor.cgColor
        progressComponent.strokeColor = progressBarColor.cgColor
    }
    
    private func updateProgressBarWidth() {
        progressComponent.lineWidth = progressBarWidth
        updateLineLayers()
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
    }
    
    func forceBeginRefreshing() {
        isAnimating = false
        startAnimating()
    }
    
    open func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        applyProgressAnimations()
    }
    
    open func stopAnimating(completion: (() -> Void)? = nil) {
        guard isAnimating else { return }
        isAnimating = false
        removeProgressAnimations()
        completion?()
    }
    
    // MARK: - Private
    
    private func applyProgressAnimations() {
        applySecondComponentAnimations(to: progressComponent)
    }
    
    private func applySecondComponentAnimations(to layer: CALayer) {
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.values = [0.5, 1]
        strokeEndAnimation.keyTimes = [0, 1]
        
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStartAnimation.values = [0.5, 0]
        strokeStartAnimation.keyTimes = [0, 1]
       
        [strokeEndAnimation, strokeStartAnimation].forEach {
            $0.duration = animationDuration
            $0.repeatCount = .infinity
            $0.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
        }
        
        layer.add(strokeStartAnimation, forKey: "secondComponentStrokeStart")
        layer.add(strokeEndAnimation, forKey: "secondComponentStrokeEnd")
    }
    
    private func removeProgressAnimations() {
        progressComponent.removeAllAnimations()
    }
}
