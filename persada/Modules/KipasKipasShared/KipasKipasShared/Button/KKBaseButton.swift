import UIKit

open class KKBaseButton: UIButton {
    
    public enum State {
        case normal
        case disabled
    }
    
    private var disabledColor: UIColor? = .gainsboro
    
    private var enabledColor: UIColor? {
        didSet {
            backgroundColor = enabledColor
        }
    }
    
    private var color: UIColor? {
        return buttonState == .normal ? enabledColor : disabledColor
    }
    
    private var buttonState: State = .normal {
        didSet {
            backgroundColor = color
        }
    }
    
    open override var isEnabled: Bool {
        didSet {
            buttonState = isEnabled ? .normal : .disabled
        }
    }
    
    public var font: UIFont? {
        didSet {
            titleLabel?.font = font
        }
    }
    
    public var titleColor: UIColor? = .black {
        didSet {
            titleLabel?.textColor = titleColor
        }
    }
    
    private var gradientLayer: CAGradientLayer?
    private var gradientBorderLayer: CAGradientLayer?
    
    public var gradientLayerColors: [UIColor] = [] {
        didSet {
            if gradientLayerColors.isEmpty {
                gradientLayer?.removeFromSuperlayer()
                gradientLayer = nil
            } else {
                setupGradient()
            }
        }
    }
    
    public var gradientLayerLocations: [NSNumber] = [] {
        didSet {
            setupGradient()
        }
    }
    
    public var gradientBorderColors: [UIColor] = [] {
        didSet {
            if gradientBorderColors.isEmpty {
                gradientBorderLayer?.removeFromSuperlayer()
                gradientBorderLayer = nil
            } else {
                setupGradientBorder()
            }
        }
    }
    
    public var borderWidth: CGFloat = 5.0 {
        didSet {
            setupGradientBorder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
        updateGradientBorderFrame()
    }
    
    public func setBackgroundColor(_ color: UIColor?, for state: State) {
        switch state {
        case .normal:
            enabledColor = color
        case .disabled:
            disabledColor = color
        }
    }
    
    public func setColor(
        title: UIColor? = nil,
        enabled: UIColor? = nil,
        disable: UIColor? = nil
    ) {
        titleColor = title
        enabledColor = enabled
        disabledColor = disable
    }
}

private extension KKBaseButton {
    func setupGradient() {
        // Remove existing gradient border layer if it exists
        if let gradientLayer = self.gradientLayer {
            gradientLayer.removeFromSuperlayer()
        }
        
        // Create the gradient layer
        let newGradientLayer = CAGradientLayer()
        newGradientLayer.colors = self.gradientLayerColors.map { $0.cgColor }
        newGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        newGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        newGradientLayer.cornerRadius = layer.cornerRadius
        newGradientLayer.locations = gradientLayerLocations
        
        // Add the gradient layer to the view's layer
        self.layer.addSublayer(newGradientLayer)
        
        // Store the gradient layer for later reference
        self.gradientLayer = newGradientLayer
        
        updateGradientFrame()
    }
    
    func updateGradientFrame() {
        gradientLayer?.frame = bounds
        gradientLayer?.masksToBounds = true
    }
    
    func setupGradientBorder() {
        // Remove existing gradient border layer if it exists
        if let gradientLayer = self.gradientBorderLayer {
            gradientLayer.removeFromSuperlayer()
        }
        
        // Create the gradient layer
        let newGradientLayer = CAGradientLayer()
        newGradientLayer.colors = gradientBorderColors.map { $0.cgColor }
        newGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        newGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        newGradientLayer.cornerRadius = layer.cornerRadius
        
        // Create a shape layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = borderWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.cornerRadius = layer.cornerRadius
        
        // Use the shape layer as a mask for the gradient layer
        newGradientLayer.mask = shapeLayer
        
        // Add the gradient layer to the view's layer
        self.layer.addSublayer(newGradientLayer)
        
        // Store the gradient layer for later reference
        self.gradientBorderLayer = newGradientLayer
        
        updateGradientBorderFrame()
    }
    
    func updateGradientBorderFrame() {
        gradientBorderLayer?.frame = bounds
        
        if let shapeLayer = gradientBorderLayer?.mask as? CAShapeLayer {
            let path = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: layer.cornerRadius
            )
            shapeLayer.path = path.cgPath
        }
    }
}

public extension KKBaseButton {
    @objc static var debounceDelay: Double = 0.3
    @objc func debounce(delay: Double = KKBaseButton.debounceDelay, siblings: [UIControl] = []) {
        isUserInteractionEnabled = false
        
        let deadline = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.isUserInteractionEnabled = true
        }
    }
}
