import UIKit

enum LoadingResult {
    case success
    case failed
}

public typealias KKSwitchLoadingStarted = () -> Void

@IBDesignable open class KKSwitch: BaseControl {
    
    open var loadingStarted: KKSwitchLoadingStarted?
    
    // MARK: - Views
    fileprivate lazy var thumbLayer: CALayer = {
        let layer = CALayer()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.contentsGravity = .resizeAspect
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()
    
    fileprivate lazy var trackLayer: CALayer = {
        let shape = CALayer()
        shape.borderWidth = borderWidth
        return shape
    }()
    
    private lazy var loadingLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = thumbRadiusPadding
        shape.strokeColor = loadingColor.cgColor
        return shape
    }()
    
    var changeThumbColor: Bool = false {
        didSet {
            setThumbColor()
        }
    }
    
    private var isLoadingCompleted = false
    
    private var loadingResult: LoadingResult = .success
    
    fileprivate var isTouchDown: Bool = false {
        didSet {
            layoutSublayers(of: layer)
            changeThumbColor = true
            stateDidChange()
        }
    }
    
    // MARK: - Public Properties
    open override var isOn: Bool {
        didSet { stateDidChange() }
    }
    
    public var borderColor: UIColor? {
        didSet { setBorderColor() }
    }
    
    public var onBorderColor: UIColor = .white {
        didSet { setBorderColor() }
    }
    
    public var offBorderColor: UIColor = .white {
        didSet { setBorderColor() }
    }
    
    public var isLoadingEnabled: Bool = false
    
    public var borderWidth: CGFloat = 2 {
        didSet {
            trackLayer.borderWidth = borderWidth
            layoutSublayers(of: layer)
        }
    }
    
    public var thumbRadiusPadding: CGFloat = 4 {
        didSet {
            layoutSublayers(of: layer)
        }
    }
    
    public var thumbCornerRadius: CGFloat = 0 {
        didSet {
            layoutThumbLayer(for: layer.bounds)
        }
    }
    
    public var thumbTintColor: UIColor? {
        didSet { setThumbColor() }
    }
    
    public var onThumbTintColor: UIColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1) {
        didSet { setThumbColor() }
    }
    
    public var offThumbTintColor: UIColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 1) {
        didSet { setThumbColor() }
    }
    
    public var loadingColor: UIColor = #colorLiteral(red: 0.2855720818, green: 0.8943144679, blue: 0.6083024144, alpha: 1) {
        didSet { loadingLayer.strokeColor = loadingColor.cgColor }
    }
    
    public var onTintColor: UIColor = #colorLiteral(red: 0.2855720818, green: 0.8943144679, blue: 0.6083024144, alpha: 1) {
        didSet {
            trackLayer.backgroundColor = getBackgroundColor()
            
            setNeedsLayout()
        }
    }
    
    public var offTintColor: UIColor = #colorLiteral(red: 0.823615551, green: 0.8911703229, blue: 0.9554550052, alpha: 1) {
        didSet {
            trackLayer.backgroundColor = getBackgroundColor()
            setNeedsLayout()
        }
    }
    
    // MARK: - initializers
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        controlDidLoad()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controlDidLoad()
    }
    
    // MARK: - Common Init
    
    fileprivate func controlDidLoad() {
        [trackLayer, thumbLayer].forEach(layer.addSublayer)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 10
        backgroundColor = .clear
        
        trackLayer.backgroundColor = getBackgroundColor()
        setThumbColor()
        addTouchHandlers()
    }
    
    fileprivate func getThumbSize() -> CGSize {
        let height = bounds.height
        return CGSize(width: height, height: height)
    }
    
    final func getThumbOrigin(for width: CGFloat) -> CGPoint {
        if isTouchDown {
            return CGPoint(x: bounds.midX - width / 2, y: 0)
        } else {
            let x = isOn ? bounds.width - width : 0
            return CGPoint(x: x, y: 0)
        }
    }
    
    fileprivate func getTackSize() -> CGSize {
        isTouchDown ? CGSize(width: bounds.height, height: bounds.height) : bounds.size
    }
    
    final func getTrackOrigin(for width: CGFloat) -> CGPoint {
        if isTouchDown {
            return CGPoint(x: bounds.midX - width/2, y: 0)
        }
        
        let inset: CGFloat = 0.0
        let x = !isOn ? bounds.width - width : inset
        return CGPoint(x: x, y: inset)
    }
    
    private func stateDidChange() {
        trackLayer.backgroundColor = getBackgroundColor()
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        layoutTrackLayer(for: layer.bounds)
        layoutThumbLayer(for: layer.bounds)
        layoutLoadingLayer(for: layer.bounds)
        
        setBorderColor()
    }
    
    @objc public final func loadingCompleted(isSuccessFull: Bool) {
        isLoadingCompleted = true
        isSuccessFull ? (loadingResult = .success) : (loadingResult = .failed)
        
        if !isSuccessFull {
            isOn.toggle()
        }
        
        loadingLayer.removeRotationAnimation()
        loadingLayer.removeFromSuperlayer()
        
        CATransaction.setCompletionBlock {
            self.isTouchDown = false
            self.isUserInteractionEnabled = true
        }
    }
}

// MARK: - layout Layers

private extension KKSwitch {
    func layoutTrackLayer(for bounds: CGRect) {
        let size = getTackSize()
        let origin = getTrackOrigin(for: size.width)
        trackLayer.frame = CGRect(origin: origin, size: size)
        trackLayer.cornerRadius = trackLayer.bounds.midY
    }
    
    func layoutThumbLayer(for bounds: CGRect) {
        let size = getThumbSize()
        let origin = getThumbOrigin(for: size.width)
        thumbLayer.frame = CGRect(origin: origin, size: size)
        thumbLayer.cornerRadius = thumbLayer.bounds.midY
    }
    
    func layoutLoadingLayer(for bounds: CGRect) {
        loadingLayer.lineWidth = thumbRadiusPadding
        
        let loadingBounds = bounds.insetBy(dx: 0, dy: borderWidth + loadingLayer.lineWidth/2)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let bezierPath = UIBezierPath(arcCenter: center, radius: bounds.midY, startAngle: -110.degreesToRadians, endAngle: -60.degreesToRadians, clockwise: true)
        loadingLayer.frame = loadingBounds
        loadingLayer.path = bezierPath.cgPath
    }
}

// MARK: - Touches

private extension KKSwitch {
    private func addTouchHandlers() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside])
        addTarget(self, action: #selector(touchEnded), for: [.touchDragExit, .touchCancel])
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftRight(_:)))
        leftSwipeGesture.direction = [.left]
        addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftRight(_:)))
        rightSwipeGesture.direction = [.right]
        addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc
    func swipeLeftRight(_ gesture: UISwipeGestureRecognizer) {
        let canLeftSwipe = isOn && gesture.direction == .left
        let canRightSwipe = !isOn && gesture.direction == .right
        guard canLeftSwipe || canRightSwipe else { return }
        touchUp()
    }
    
    @objc
    func touchDown() {
        isLoadingCompleted = false
        isTouchDown = true
    }
    
    @objc
    func touchUp() {
        isOn.toggle()
        touchEnded()
    }
    
    @objc
    func touchEnded() {
        valueChange?(isOn)
        
        if isLoadingEnabled {
            performLoading()
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isTouchDown = false
            }
        }
    }
}

// MARK: - color setting

private extension KKSwitch {
    func setThumbColor() {
        if let thumbColor = thumbTintColor {
            thumbLayer.backgroundColor = thumbColor.cgColor
        } else {
            thumbLayer.backgroundColor = (isOn ? onThumbTintColor : offThumbTintColor).cgColor
        }
    }
    
    func getBackgroundColor() -> CGColor {
        return ((isOn && !isTouchDown) ? onTintColor : offTintColor).cgColor
    }
    
    func setBorderColor() {
        if let borderClor = borderColor {
            trackLayer.borderColor = borderClor.cgColor
        } else {
            trackLayer.borderColor = (isOn ? onBorderColor : offBorderColor).cgColor
        }
    }
}

// MARK: - Loading Animation
private extension KKSwitch {
    func performLoading() {
        loadingStarted?()
        layer.addSublayer(loadingLayer)
        isUserInteractionEnabled = false
        loadingLayer.rotateAnimation(angal: 360.degreesToRadians, duration: 1, repeatAnimation: true)
    }
}
