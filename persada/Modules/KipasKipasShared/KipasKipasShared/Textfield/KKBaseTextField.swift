import UIKit

open class KKBaseTextField: UITextField {
    
    public var isError: Bool = false
    
    public var hidePlaceholderWhenBeginEditing: Bool = false
    
    @IBInspectable public var placeholderColor: UIColor? {
        get {
            placeholderLabel.textColor
        } set {
            placeholderLabel.textColor = newValue
        }
    }
    /// The styled string for a custom placeholder.
    public var attributedPlaceholderText: NSAttributedString? {
        get {
            placeholderLabel.attributedText
        } set {
            setAttributedPlaceholderText(newValue)
        }
    }
    
    /// The string that is displayed when there is no other text in the text field.
    @IBInspectable public var placeholderText: String? {
        get {
            placeholderLabel.text
        } set {
            setPlaceholderText(newValue)
        }
    }
    
    public var insets: UIEdgeInsets = .zero {
        didSet {
            layoutIfNeeded()
        }
    }
    
    /// Custom placeholder label. You can use it to style placeholder text.
    public private(set) lazy var placeholderLabel = UILabel()
    
    ///    The current text that is displayed by the label.
    override open var text: String? {
        didSet {
            setPlaceholderVisibility()
        }
    }
    
    /// The styled text displayed by the text field.
    override open var attributedText: NSAttributedString? {
        didSet {
            setPlaceholderVisibility()
        }
    }
    
    /// The technique to use for aligning the text.
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    // MARK: Constraints
    private let placeholderLayoutGuide = UILayoutGuide()
    
    private var leadingPlaceholderConstraint: NSLayoutConstraint? {
        didSet {
            leadingPlaceholderConstraint?.isActive = true
        }
    }
    
    private var trailingPlaceholderConstraint: NSLayoutConstraint? {
        didSet {
            trailingPlaceholderConstraint?.isActive = true
        }
    }
    
    private var bottomPlaceholderConstraint: NSLayoutConstraint? {
        didSet {
            bottomPlaceholderConstraint?.isActive = true
        }
    }
    
    private var centerYPlaceholderConstraint: NSLayoutConstraint? {
        didSet {
            centerYPlaceholderConstraint?.isActive = true
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        configurePlaceholderLabel()
        setPlaceholderVisibility()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        configurePlaceholderInsets()
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds.inset(by: insets))
    }
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds.inset(by: insets))
    }
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds.inset(by: insets))
    }
    
    private func commonInit() {
        observe()
        configurePlaceholderLabel()
        overrideUserInterfaceStyle = .light
    }
    
    private func configurePlaceholderLabel() {
        placeholderLabel.textAlignment = textAlignment
    }
    
    private func setPlaceholderText(_ text: String?) {
        addPlaceholderLabelIfNeeded()
        placeholderLabel.text = text
    }
    
    private func setAttributedPlaceholderText(_ text: NSAttributedString?) {
        addPlaceholderLabelIfNeeded()
        placeholderLabel.attributedText = text
    }
    
    private func observe() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditing),
            name: UITextField.textDidBeginEditingNotification,
            object: self
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(textFieldDidEndEditing),
            name: UITextField.textDidEndEditingNotification,
            object: self
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(textFieldDidEndEditing),
            name: UITextField.textDidChangeNotification,
            object: self
        )
    }
    
    @objc private func textFieldDidBeginEditing() {
        if let text = text, text.isEmpty {
            placeholderLabel.isHidden = hidePlaceholderWhenBeginEditing
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    @objc private func textFieldDidEndEditing() {
        if let text = text, text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
    private func setPlaceholderVisibility() {
        if let text = text, let attributedText = attributedText {
            placeholderLabel.isHidden = text.isEmpty == false || attributedText.string.isEmpty == false
        }
    }
    
    private func addPlaceholderLabelIfNeeded() {
        if placeholderLabel.superview != nil {
            return
        }
        
        addLayoutGuide(placeholderLayoutGuide)
        addSubview(placeholderLabel)
        
        leadingPlaceholderConstraint = placeholderLabel.anchors.leading.equal(anchors.leading)
        trailingPlaceholderConstraint = placeholderLabel.anchors.trailing.equal(anchors.trailing)
        bottomPlaceholderConstraint = placeholderLabel.anchors.bottom.equal(placeholderLayoutGuide.anchors.bottom)
        centerYPlaceholderConstraint = placeholderLabel.anchors.centerY.equal(anchors.centerY)
        centerYPlaceholderConstraint?.priority = .defaultHigh
        
        placeholderLayoutGuide.anchors.edges.pin()
        
        configurePlaceholderInsets()
    }
    
    private func configurePlaceholderInsets() {
        let placeholderRect = placeholderRect(forBounds: bounds)
        
        leadingPlaceholderConstraint?.constant = placeholderRect.origin.x

        let trailing = bounds.width - placeholderRect.maxX
        trailingPlaceholderConstraint?.constant = -trailing

        bottomPlaceholderConstraint?.constant = -insets.bottom
        centerYPlaceholderConstraint?.constant = -insets.bottom
    }
}

public extension KKBaseTextField {
    func setCursorPosition(position: Int) {
        guard let text = text, position <= text.count && position >= 0 else {
            return
        }
        
        if let position = self.position(from: beginningOfDocument, offset: position) {
            selectedTextRange = textRange(from: position, to: position)
        }
    }
    
    func becomeFirstResponderIfNeeded() {
        guard isFirstResponder == false else { return }
        becomeFirstResponder()
    }
}
