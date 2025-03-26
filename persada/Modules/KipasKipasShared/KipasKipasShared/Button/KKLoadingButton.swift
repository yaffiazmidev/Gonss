import UIKit

public typealias LBCallback = (() -> Void)?

open class KKLoadingButton: KKBaseButton {
    
    public enum IconPosition {
        case none
        case left
        case right
    }
    
    public enum IndicatorPosition {
        case center
        case right
    }
    
    public var iconInset: CGFloat = 0.0
    public var titleInsets: UIEdgeInsets = .zero
    
    // MARK: - Public variables
    /**
     Current loading state.
     */
    public var isLoading: Bool = false
    /**
     The flag that indicate if the shadow is added to prevent duplicate drawing.
     */
    public var shadowAdded: Bool = false
    // MARK: - Package-protected variables
    /**
     The loading indicator used with the button.
     */
    open var indicator: UIView & KKLoadingIndicator = UIActivityIndicatorView()
    
    /**
     The icon position of the button
     */
    open var iconPosition: IconPosition = .left {
        didSet {
            layoutIfNeeded()
        }
    }
    
    /**
     The indicator position of the button
     */
    open var indicatorPosition: IndicatorPosition = .center {
        didSet {
            layoutIfNeeded()
        }
    }
    
    open var adjustsFontSizeToFitWidth : Bool = false {
        didSet {
            titleLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        }
    }
    
    /**
     Set to true to add shadow to the button.
     */
    open var withShadow: Bool = false
    /**
     The corner radius of the button
     */
    open var cornerRadius: CGFloat = 12.0 {
        didSet {
            self.clipsToBounds = (self.cornerRadius > 0)
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    /**
     Button background color
     */
    public var bgColor: UIColor = .lightGray {
        didSet {
            setBackgroundColor(bgColor, for: .normal)
        }
    }
    /**
     Shadow view.
     */
    open var shadowLayer: UIView?
    /**
     Get all views in the button. Views include the button itself and the shadow.
     */
    open var entireViewGroup: [UIView] {
        var views: [UIView] = [self]
        if let shadow = self.shadowLayer {
            views.append(shadow)
        }
        return views
    }
    /**
     Button style for light mode and dark mode use. Only available on iOS 13 or later.
     */
    @available(iOS 13.0, *)
    public enum ButtonStyle {
        case fill
        case outline
    }
    // Private properties
    private var imageAlpha: CGFloat = 1.0
    private var loaderWorkItem: DispatchWorkItem?
    // Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    /**
     Convenience init of theme button with required information
     
     - Parameter icon:      the icon of the button, it is be nil by default.
     - Parameter text:      the title of the button.
     - Parameter textColor: the text color of the button.
     - Parameter textSize:  the text size of the button label.
     - Parameter bgColor:   the background color of the button, tint color will be automatically generated.
     */
    public init(
        frame: CGRect = .zero,
        icon: UIImage? = nil,
        iconPosition: IconPosition = .left,
        text: String? = nil,
        textColor: UIColor? = .white,
        font: UIFont? = nil,
        bgColor: UIColor = .black,
        cornerRadius: CGFloat = 12.0,
        withShadow: Bool = false
    ) {
        super.init(frame: frame)
        // Set the icon of the button
        if let icon = icon {
            self.setImage(icon)
            self.iconPosition = iconPosition
        }
        // Set the title of the button
        if let text = text {
            self.setTitle(text)
            self.setTitleColor(textColor, for: .normal)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        // Set button contents
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.titleLabel?.font = font
        self.bgColor = bgColor
        self.backgroundColor = bgColor
        self.setBackgroundImage(UIImage(.lightGray), for: .disabled)
        self.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.setCornerBorder(cornerRadius: cornerRadius)
        self.withShadow = withShadow
        self.cornerRadius = cornerRadius
    }
    /**
     Convenience init of material design button using system default colors. This initializer
     reflects dark mode colors on iOS 13 or later platforms. However, it will ignore any custom
     colors set to the button.
     
     - Parameter icon:         the icon of the button, it is be nil by default.
     - Parameter text:         the title of the button.
     - Parameter font:         the font of the button label.
     - Parameter cornerRadius: the corner radius of the button. It is set to 12.0 by default.
     - Parameter withShadow:   set true to show the shadow of the button.
     - Parameter buttonStyle:  specify the button style. Styles currently available are fill and outline.
     */
    @available(iOS 13.0, tvOS 13.0, *)
    public convenience init(
        icon: UIImage? = nil,
        iconPosition: IconPosition = .left,
        text: String? = nil,
        font: UIFont? = nil,
        cornerRadius: CGFloat = 12.0,
        withShadow: Bool = false,
        buttonStyle: ButtonStyle
    ) {
        switch buttonStyle {
        case .fill:
#if os(tvOS)
            self.init(icon: icon, text: text, textColor: .label, font: font,
                      bgColor: .clear, cornerRadius: cornerRadius, withShadow: withShadow)
#else
            self.init(icon: icon, iconPosition: iconPosition, text: text, textColor: .label, font: font,
                      bgColor: .systemFill, cornerRadius: cornerRadius, withShadow: withShadow)
#endif
        case .outline:
            self.init(icon: icon, iconPosition: iconPosition, text: text, textColor: .label, font: font,
                      bgColor: .clear, cornerRadius: cornerRadius, withShadow: withShadow)
            self.setCornerBorder(color: .label, cornerRadius: cornerRadius)
        }
        self.indicator.color = .label
    }
    // draw
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if shadowAdded || !withShadow { return }
        shadowAdded = true
        // Set up shadow layer
        shadowLayer = UIView(frame: self.frame)
        guard let shadowLayer = shadowLayer else { return }
        shadowLayer.setAsShadow(bounds: bounds, cornerRadius: self.cornerRadius)
        self.superview?.insertSubview(shadowLayer, belowSubview: self)
    }
    // Required init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /**
     Set the icon position of the button
     */
    private func setIconPosition() {
        switch iconPosition {
        case .right:
            guard let imageViewWidth = imageView?.frame.width else { return }
            guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else { return }
            semanticContentAttribute = .forceRightToLeft
            contentHorizontalAlignment = .right
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: imageViewWidth / 4)
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: (bounds.width - (titleLabelWidth)) / 4)
            
        case .left:
            guard let imageViewWidth = imageView?.frame.width else { return }
            guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else { return }
            semanticContentAttribute = .forceLeftToRight
            contentHorizontalAlignment = .left
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: iconInset, bottom: 0.0, right: 0.0)
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - (titleLabelWidth - 6.0) + titleInsets.left) / 2 - imageViewWidth + titleInsets.left, bottom: 0.0, right: titleInsets.right)
        case .none:
            imageEdgeInsets = .zero
            titleEdgeInsets = .zero
            contentHorizontalAlignment = .fill
        }
    }
    
    private func setIndicatorPosition() {
        switch indicatorPosition {
        case .center:
            indicator.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        case .right:
            indicator.center = CGPoint(x: self.frame.size.width - 32, y: self.frame.size.height/2)
        }
    }
    
    /**
     Display the loader inside the button.
     
     - Parameter userInteraction: Enable the user interaction while displaying the loader.
     - Parameter completion:      The completion handler.
     */
    open func showLoader(userInteraction: Bool, _ completion: LBCallback = nil) {
        showLoader([titleLabel, imageView], userInteraction: userInteraction, completion)
    }
    /**
     Show a loader inside the button with image.
     
     - Parameter userInteraction: Enable user interaction while showing the loader.
     */
    open func showLoaderWithImage(userInteraction: Bool = false) {
        showLoader([self.titleLabel], userInteraction: userInteraction)
    }
    /**
     Display the loader inside the button.
     
     - Parameter viewsToBeHidden: The views such as titleLabel, imageViewto be hidden while showing loading indicator.
     - Parameter userInteraction: Enable the user interaction while displaying the loader.
     - Parameter completion:      The completion handler.
     */
    open func showLoader(_ viewsToBeHidden: [UIView?], userInteraction: Bool = false, _ completion: LBCallback = nil) {
        guard !self.subviews.contains(indicator) else { return }
        // Set up loading indicator and update loading state
        isLoading = true
        self.isUserInteractionEnabled = userInteraction
        
        indicator.radius = min(0.7*self.frame.height/2, indicator.radius)
        indicator.alpha = 0.0
        indicator.frame = bounds
        
        self.addSubview(self.indicator)
        // Create a new work item
        loaderWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self, let item = self.loaderWorkItem, !item.isCancelled else { return }
            UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
                viewsToBeHidden.forEach { view in
                    if view == self.imageView {
                        self.imageAlpha = 0.0
                    }
                    view?.alpha = 0.0
                }
                self.indicator.alpha = 1.0
            }) { _ in
                guard !item.isCancelled else { return }
                self.isLoading ? self.indicator.startAnimating() : self.hideLoader()
                completion?()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: { [weak self] in
                self?.hideLoader()
            })
        }
        loaderWorkItem?.perform()
    }
    
    /**
     Display the loader inside the button.
     
     - Parameter viewsToBeHidden: The views such as titleLabel, imageViewto be hidden while showing loading indicator.
     - Parameter userInteraction: Enable the user interaction while displaying the loader.
     - Parameter completion:      The completion handler.
     */
    open func showLoaderWithoutLimit(_ viewsToBeHidden: [UIView?], userInteraction: Bool = false, _ completion: LBCallback = nil) {
        guard !self.subviews.contains(indicator) else { return }
        // Set up loading indicator and update loading state
        isLoading = true
        self.isUserInteractionEnabled = userInteraction
        
        indicator.radius = min(0.7*self.frame.height/2, indicator.radius)
        indicator.alpha = 0.0
        indicator.frame = bounds
        
        self.addSubview(self.indicator)
        // Create a new work item
        loaderWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self, let item = self.loaderWorkItem, !item.isCancelled else { return }
            UIView.transition(with: self, duration: 0.2, options: .curveEaseOut, animations: {
                viewsToBeHidden.forEach { view in
                    if view == self.imageView {
                        self.imageAlpha = 0.0
                    }
                    view?.alpha = 0.0
                }
                self.indicator.alpha = 1.0
            }) { _ in
                guard !item.isCancelled else { return }
                self.isLoading ? self.indicator.startAnimating() : self.hideLoader()
                completion?()
            }
        }
        loaderWorkItem?.perform()
    }
    /**
     Hide the loader displayed.
     
     - Parameter completion: The completion handler.
     */
    open func hideLoader(_ completion: LBCallback = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.subviews.contains(self.indicator) else { return }
            // Update loading state
            self.isLoading = false
            self.isUserInteractionEnabled = true
            self.indicator.stopAnimating()
            // Clean up
            self.indicator.finish {
                self.titleLabel?.alpha = 1.0
                self.imageView?.alpha = 1.0
                self.imageAlpha = 1.0
                completion?()
            } 
            self.loaderWorkItem?.cancel()
            self.loaderWorkItem = nil
        }
    }
    /**
     Make the content of the button fill the button.
     */
    public func fillContent() {
        self.contentVerticalAlignment = .fill
        self.contentHorizontalAlignment = .fill
    }
    // layoutSubviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            imageView.alpha = imageAlpha
            setIconPosition()
        }
        setIndicatorPosition()
    }
}
// MARK: - UIActivityIndicatorView
extension UIActivityIndicatorView: KKLoadingIndicator {
    public var radius: CGFloat {
        get {
            return self.frame.width/2
        }
        set {
            self.frame.size = CGSize(width: 2*newValue, height: 2*newValue)
            self.setNeedsDisplay()
        }
    }
    
    public var color: UIColor {
        get {
            return self.tintColor
        }
        set {
            let ciColor = CIColor(color: newValue)
            #if os(iOS)
            self.style = newValue.RGBtoCMYK(red: ciColor.red, green: ciColor.green, blue: ciColor.blue).key > 0.5 ? .large : .whiteLarge
            #endif
            self.tintColor = newValue
        }
    }
    
    // unused
    public func setupAnimation(in layer: CALayer, size: CGSize) {}
    public func finish(completion: @escaping () -> Void) {
        self.removeFromSuperview()
        completion()
    }
}

// MARK: - UIImage
extension UIImage {
    /**
     Create color rectangle as image.
     
     - Parameter color: The color to be created as an UIImage
     - Parameter size:  The size of the UIImage, no need to be set when creating
     */
    public convenience init?(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil}
        self.init(cgImage: cgImage)
    }
}

// MARK: - UIButton
extension UIButton {
    /**
     Set button image for all button states
     
     - Parameter image: The image to be set to the button.
     */
    public func setImage(_ image: UIImage?) {
        for state : UIControl.State in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
            self.setImage(image?.withRenderingMode(.alwaysOriginal), for: state)
        }
    }
    /**
     Set button title for all button states
     
     - Parameter text: The text to be set to the button title.
     */
    public func setTitle(_ text: String?) {
        for state : UIControl.State in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
            self.setTitle(text, for: state)
        }
    }
}

extension UIColor {
    /**
     Convert RGB value to CMYK value.
     
     - Parameter red: The red value of RGB.
     - Parameter green: The green value of RGB.
     - Parameter blue: The blue value of RGB.
     
     Returns a 4-tuple that represents the CMYK value converted from input RGB.
     */
    public func RGBtoCMYK(
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat
    ) -> (
        cyan: CGFloat,
        magenta: CGFloat,
        yellow: CGFloat,
        key: CGFloat
    ) {
        // Base case
        if red == 0, green == 0, blue == 0 {
            return (0, 0, 0, 1)
        }
        var cyan = 1 - red
        var magenta = 1 - green
        var yellow = 1 - blue
        let minCMY = min(cyan, magenta, yellow)
        cyan = (cyan - minCMY) / (1 - minCMY)
        magenta = (magenta - minCMY) / (1 - minCMY)
        yellow = (yellow - minCMY) / (1 - minCMY)
        return (cyan, magenta, yellow, minCMY)
    }
    /**
     Convert CMYK value to RGB value.
     
     - Parameter cyan: The cyan value of CMYK.
     - Parameter magenta: The magenta value of CMYK.
     - Parameter yellow: The yellow value of CMYK.
     - Parameter key: The key/black value of CMYK.
     
     Returns a 3-tuple that represents the RGB value converted from input CMYK.
     */
    public func CMYKtoRGB(
        cyan: CGFloat,
        magenta: CGFloat,
        yellow: CGFloat,
        key: CGFloat
    ) -> (
        red: CGFloat,
        green: CGFloat,
        blue: CGFloat
    ) {
        let red = (1 - cyan) * (1 - key)
        let green = (1 - magenta) * (1 - key)
        let blue = (1 - yellow) * (1 - key)
        return (red, green, blue)
    }
    /**
     Get the tint color of the current color.
     */
    public func getColorTint() -> UIColor {
        let ciColor = CIColor(color: self)
        let originCMYK = RGBtoCMYK(red: ciColor.red, green: ciColor.green, blue: ciColor.blue)
        let kVal = originCMYK.key > 0.3 ? originCMYK.key - 0.2 : originCMYK.key + 0.2
        let tintRGB = CMYKtoRGB(cyan: originCMYK.cyan, magenta: originCMYK.magenta, yellow: originCMYK.yellow, key: kVal)
        return UIColor(red: tintRGB.red, green: tintRGB.green, blue: tintRGB.blue, alpha: 1.0)
    }
}

// MARK: UIView
extension UIView {
    /**
     Set the corner radius of the view.
     
     - Parameter color:        The color of the border.
     - Parameter cornerRadius: The radius of the rounded corner.
     - Parameter borderWidth:  The width of the border.
     */
    public func setCornerBorder(color: UIColor? = nil, cornerRadius: CGFloat = 15.0, borderWidth: CGFloat = 1.5) {
        self.layer.borderColor = color != nil ? color!.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    /**
     Set the shadow layer of the view.
     
     - Parameter bounds:       The bounds in CGRect of the shadow.
     - Parameter cornerRadius: The radius of the shadow path.
     - Parameter shadowRadius: The radius of the shadow.
     */
    public func setAsShadow(bounds: CGRect, cornerRadius: CGFloat = 0.0, shadowRadius: CGFloat = 1) {
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = false
    }
}
