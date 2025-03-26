import UIKit
import KipasKipasShared

public final class KKScrollableCaptionView: UIView {
    
    public var text: String = "" {
        didSet {
           expandToggleButton.isHidden = shouldHideToggleButton
           shouldUpdateContentAndSize()
        }
    }
    
    public var font: UIFont = .roboto(.regular, size: 15)  {
        didSet {
            captionLabel?.font = font
        }
    }
    
    public var attributeFont: UIFont = .roboto(.medium, size: 15) {
        didSet {
            captionLabel?.font = font
        }
    }
    
    public var textColor: UIColor = .white {
        didSet {
           captionLabel?.textColor = textColor
        }
    }
    
    public var expandToggleTextColor: UIColor = .white {
        didSet {
            expandToggleButton.setTitleColor(expandToggleTextColor, for: .normal)
        }
    }
    
    public var attributeTextColor: UIColor = .white

    public private(set) var isExpanded: Bool = false {
        didSet {
            scrollContainer.isScrollEnabled = isExpanded
            expandToggleButton.setTitle(isExpanded ? "less" : "more", for: .normal)
            shouldUpdateContentAndSize()
        }
    }
    
    private var heightConstraint: NSLayoutConstraint! {
        didSet {
            heightConstraint.isActive = true
        }
    }
    
    private var shouldHideToggleButton: Bool {
        return text.count <= captionLabel?.textLimit ?? 0
    }
    
    private let stackContainer = UIStackView()
    private let scrollContainer = ScrollContainerView()
    //private let captionLabel: ActiveLabel? = nil
    private var captionLabel: ActiveLabel?
    private let expandToggleButton = UIButton()
    
    public var mentionTapHandler: ((String) -> Void)?
    public var hashtagTapHandler: ((String) -> Void)?
    public var toggleExpandHandler: ((Bool) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        captionLabel = ActiveLabel()
        configureUI()
    }
    
    func reset() {
        if isExpanded {
            toggleExpand()
        }
    }
    
    func addDropShadow(color: UIColor = .black, radius: CGFloat, opacity: Float, offset: CGSize = .init(width: 0, height: 0)) {
        captionLabel?.addDropShadow(color: color, radius: radius, opacity: opacity, offset: offset)
    }
}

// MARK: UI
private extension KKScrollableCaptionView {
    func configureUI() {
        configureStackView()
        configureContainer()
        configureExpandToggleButton()
        heightConstraint = anchors.height.equal(250)//markY constraints 300 in xib
    }
    
    func configureStackView() {
        stackContainer.axis = .vertical
        stackContainer.alignment = .leading
        stackContainer.spacing = 4
        
        addSubview(stackContainer)
        stackContainer.anchors.top.pin()
        stackContainer.anchors.leading.pin()
        stackContainer.anchors.trailing.pin()
        stackContainer.anchors.bottom.pin()
    }
    
    func configureContainer() {
        scrollContainer.isScrollEnabled = isExpanded
        scrollContainer.addArrangedSubViews(captionLabel!)
        stackContainer.addArrangedSubview(scrollContainer)
    }
   
    func configureExpandToggleButton() {
        expandToggleButton.isHidden = true
        expandToggleButton.setTitle(isExpanded ? "less" : "more", for: .normal)
        expandToggleButton.titleLabel?.font = .roboto(.medium, size: 15)
        expandToggleButton.setTitleColor(.white, for: .normal)
        expandToggleButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
        
        stackContainer.addArrangedSubview(expandToggleButton)
        expandToggleButton.anchors.height.equal(20)
    }
    
    func updateContainerConstraint() {
        let caption = captionLabel?.text ?? text
        let textSum = caption.isEmpty ? "" : caption + "\n\n"
        let textHeight = textSum.height(withConstrainedWidth: 250, font: font)
        
        let halfScreenHeight = UIScreen.main.bounds.height * 0.45
        let height = textHeight < halfScreenHeight ? textHeight : halfScreenHeight
        
        heightConstraint.constant = height
        
        self.layoutIfNeeded()
    }
    
    @objc func toggleExpand() {
        isExpanded.toggle()
        toggleExpandHandler?(isExpanded)
    }
    
    func shouldUpdateContentAndSize() {
        captionLabel?.setCaption(
            text: text,
            shouldTrim: !isExpanded,
            attributeFont: attributeFont,
            attributeColor: attributeTextColor,
            mentionTap: { [weak self] in
                self?.mentionTapHandler?($0)
            },
            hashtagTap: { [weak self] in
                self?.hashtagTapHandler?($0)
            }
        )
        updateContainerConstraint()
    }
}

private extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
