import UIKit

#if os(iOS)

@available(iOSApplicationExtension, unavailable)
open class KKFloatingToastView: UIView {
    
    @objc dynamic open var duration: TimeInterval = 1.5
    
    open var radius: CGFloat = 8
    open var direction: KBFloatingToastDirection = .top
    open var easingWhenVisible: Bool = false
    open var completion: (() -> Void)? = nil
    open var callbackOnClick: (() -> Void)?
    
    open var isPresentable: Bool = true
    open var haptic: KKFloatingToastHaptic = .success
    
    open var textColor: UIColor = .gravel {
        didSet {
            titleLabel?.textColor = textColor
        }
    }
    
    open var titleLabel: UILabel?
    open var subtitleLabel: UILabel?
    
    open var leftIconView: UIView? {
        didSet {
            setLeftIcon(for: leftIconView)
        }
    }
    
    open var rightIconView: UIView? {
        didSet {
            setRightIcon(for: rightIconView)
        }
    }
    
    private var temporaryLeftIconView: UIView?
    private var temporaryRightIconView: UIView?
    
    weak open var presentWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
           return UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first
        }
    }()
    
    // MARK: - Init
    
    public init(title: String? = nil, subtitle: String? = nil, leftIconView: UIView? = nil, rightIconView: UIView? = nil) {
        super.init(frame: .zero)
        commonInit()
        layout = KKFloatingToastViewLayout()
        
        setTitle(title)
        setSubtitle(subtitle)
        self.leftIconView = leftIconView
        self.rightIconView = rightIconView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.direction = .top
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        preservesSuperviewLayoutMargins = false
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        backgroundColor = .white
        isUserInteractionEnabled  = true
        
        setShadow()
        setGesture()
    }
    
    // MARK: - Configure
    private func setTitle(_ text: String?) {
        let label = UILabel()
        label.font = .roboto(.medium, size: 14)
        label.numberOfLines = 1
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        style.lineSpacing = 3
        label.attributedText = NSAttributedString(
            string: text ?? "", attributes: [.paragraphStyle: style]
        )
        label.textAlignment = .center
        label.textColor = textColor
        titleLabel = label
        addSubview(label)
    }
    
    private func setSubtitle(_ text: String?) {
        let label = UILabel()
        label.font = .roboto(.regular, size: 10)
        label.numberOfLines = 1
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        style.lineSpacing = 2
        label.attributedText = NSAttributedString(
            string: text ?? "", attributes: [.paragraphStyle: style]
        )
        label.textAlignment = .center
        label.textColor = textColor
        subtitleLabel = label
        addSubview(label)
    }
    
    private func setLeftIcon(for view: UIView?) {
        guard let view = view else {
            self.temporaryLeftIconView?.removeFromSuperview()
            return
        }
        self.temporaryLeftIconView?.removeFromSuperview()
        self.temporaryLeftIconView = view
        addSubview(view)
    }
    
    private func setRightIcon(for view: UIView?) {
        guard let view = view else {
            self.temporaryRightIconView?.removeFromSuperview()
            return
        }
        self.temporaryRightIconView?.removeFromSuperview()
        self.temporaryRightIconView = view
        addSubview(view)
    }
    
    private func setShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 40
    }
    
    private func setGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Present
    
    private var presentAndDismissDuration: TimeInterval = 0.6
    
    open func present(completion: (() -> Void)? = nil) {
        present(duration: self.duration, haptic: haptic, completion: completion)
    }
    
    open func present(duration: TimeInterval, haptic: KKFloatingToastHaptic = .success, completion: (() -> Void)? = nil) {
        
        guard isPresentable else { return }
        
        prepareForPresent(completion: completion)
        
        presentSelf(duration: duration)
    }
    
    @objc open func dismiss() {
        UIView.animate(withDuration: presentAndDismissDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
            self.changeState(.prepare(self.direction))
        }, completion: { _ in
            self.layer.removeAllAnimations()
            self.removeFromSuperview()
            self.completion?()
            self.isPresentable = true
        })
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        haptic.impact()
        callbackOnClick?()
    }
    
    private func prepareForPresent(completion: (() -> Void)? = nil) {
        guard let window = self.presentWindow else { return }
        window.addSubview(self)
        
        self.completion = completion
        
        alpha = 0
        isHidden = true
        sizeToFit()
        layoutSubviews()
        center.x = window.frame.midX
        changeState(.prepare(direction))
    }
    
    private func presentSelf(duration: TimeInterval) {
        isHidden = false
        UIView.animate(withDuration: presentAndDismissDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.layer.removeAllAnimations()
            self.changeState(.visible(self.direction))
            self.alpha = 1
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                self.dismiss()
            }
        })
        
        if let leftIconView = self.leftIconView as? KBFloatingToastIconAnimatable {
            animateIconView(animate: { leftIconView.animate() })
        } else if let rightIconView = self.rightIconView as? KBFloatingToastIconAnimatable {
            animateIconView(animate: { rightIconView.animate() })
        }
    }
    
    private func animateIconView(animate: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + presentAndDismissDuration / 3) {
           animate()
        }
    }
    
    private func changeState(_ state: ToastState) {
        
        let getPrepareTransform: ((_ side: KBFloatingToastDirection) -> CGAffineTransform) = { [weak self] side in
            
            guard let self = self, let window = self.presentWindow else { return .identity }
            
            switch side {
            case .top:
                let topInset = window.safeAreaInsets.top
                let position = -(topInset + 50)
                return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            case .bottom:
                let height = window.frame.height
                let bottomInset = window.safeAreaInsets.bottom
                let position = height + bottomInset + 50
                return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            }
        }
        
        let getVisibleTransform: ((_ side: KBFloatingToastDirection) -> CGAffineTransform) = { [weak self] side in
            
            guard let self = self, let window = self.presentWindow else { return .identity }
            
            // Reset
            let yOffsett = side == .bottom ? UIScreen.main.bounds.maxY + self.offset : UIScreen.main.bounds.minY - self.offset
            self.frame.origin.y = yOffsett
                
            switch side {
            case .top:
                var topSafeAreaInsets = window.safeAreaInsets.top
                if topSafeAreaInsets < 20 { topSafeAreaInsets = 20 }
                let position = topSafeAreaInsets - 3 + self.offset
                return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            case .bottom:
                let height = window.frame.height
                let bottomSafeAreaInsets: CGFloat = window.safeAreaInsets.top <= 20 ? 36 : 0
                let position = height - bottomSafeAreaInsets - 3 - self.frame.height - self.offset
                return CGAffineTransform.identity.translatedBy(x: 0, y: position)
            }
        }
        
        switch state {
        case .prepare(let direction):
            transform = getPrepareTransform(direction)
        case .visible(let direction):
            transform = getVisibleTransform(direction)
            if easingWhenVisible {
                easing()
            }
        }
    }
    
    private func easing() {
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseOut, .repeat, .autoreverse, .beginFromCurrentState, .allowUserInteraction], animations: {
            self.frame.origin.y -= 5
        }, completion: nil)
    }
    
    // MARK: - Layout
    open var layout: KKFloatingToastViewLayout = .init()
    open var offset: CGFloat = 0
    
    private var areaHeight: CGFloat = 50
    private var minimumAreaWidth: CGFloat = 160
    private var maximumAreaWidth: CGFloat = 260
    private var spaceBetweenTitles: CGFloat = 1
    private var spaceBetweenTitlesAndImage: CGFloat = 16
    
    private var titlesCompactWidth: CGFloat {
        if let leftIconView = self.leftIconView {
            let spaceLeft = leftIconView.frame.maxY + spaceBetweenTitlesAndImage
            return frame.width - spaceLeft * 1.5
            
        } else if let rightIconView = self.rightIconView {
            let spaceRight = rightIconView.frame.maxY + spaceBetweenTitlesAndImage
            return frame.width - spaceRight * 1.5
            
        } else {
            return frame.width - layoutMargins.left - layoutMargins.right
        }
    }
    
    private var titlesFullWidth: CGFloat {
        if let leftIconView = self.leftIconView {
            let space = leftIconView.frame.maxY + spaceBetweenTitlesAndImage
            return frame.width - space - layoutMargins.right - self.spaceBetweenTitlesAndImage
        } else {
            return frame.width - layoutMargins.left - layoutMargins.right
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        titleLabel?.sizeToFit()
        let titleWidth: CGFloat = titleLabel?.frame.width ?? 0
        subtitleLabel?.sizeToFit()
        let subtitleWidth: CGFloat = subtitleLabel?.frame.width ?? 0
        var width = (max(titleWidth, subtitleWidth) + layout.leftIconSize.width + layout.rightIconSize.width + (spaceBetweenTitlesAndImage * 4)).rounded()
        
        if width < minimumAreaWidth { width = minimumAreaWidth }
        if width > maximumAreaWidth { width = maximumAreaWidth }
        
        return .init(width: width, height: areaHeight)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutMargins = layout.margins
        layer.cornerRadius = radius
        
        let hasLeftIcon = (self.leftIconView != nil)
        let hasRightIcon = (self.rightIconView != nil)
        let hasTitle = (self.titleLabel != nil)
        let hasSubtitle = (self.subtitleLabel != nil && self.subtitleLabel?.text?.isEmpty == false)
        
        let fitTitleToCompact: Bool = {
            guard let titleLabel = self.titleLabel else { return true }
            titleLabel.numberOfLines = 1
            titleLabel.sizeToFit()
            return titleLabel.frame.width < titlesCompactWidth
        }()
        
        let fitSubtitleToCompact: Bool = {
            guard let subtitleLabel = self.subtitleLabel else { return true }
            subtitleLabel.numberOfLines = 1
            subtitleLabel.sizeToFit()
            return subtitleLabel.frame.width < titlesCompactWidth
        }()
        
        let notFitAnyLabelToCompact: Bool = {
            if !fitTitleToCompact { return true }
            if !fitSubtitleToCompact { return true }
            return false
        }()
        
        var layout: ToastLayout = .iconTitleCentered
        
        if (hasLeftIcon && hasTitle && hasSubtitle && hasRightIcon) && !notFitAnyLabelToCompact {
            layout = .iconTitleMessageCentered
        }
        
        if ((!hasRightIcon && hasLeftIcon) && hasTitle && hasSubtitle) && notFitAnyLabelToCompact {
            layout = .iconTitleMessageLeading
        }
        
        if ((hasLeftIcon && hasRightIcon) && hasTitle && hasSubtitle) {
            layout = .iconTitleCentered
        }
        
        if (!hasLeftIcon && hasTitle && !hasSubtitle && !hasRightIcon) {
            layout = .title
        }
        
        if (!hasLeftIcon && hasTitle && hasSubtitle && !hasRightIcon) {
            layout = .titleMessage
        }
        
        let layoutLeftIcon = { [weak self] in
            guard let self = self else { return }
            guard let leftIconView = self.leftIconView else { return }
            leftIconView.frame = .init(
                origin: .init(x: self.layoutMargins.left, y: leftIconView.frame.origin.y),
                size: self.layout.leftIconSize
            )
            leftIconView.center.y = self.bounds.midY
        }
        
        let layoutRightIcon = { [weak self] in
            guard let self = self else { return }
            guard let rightIconView = self.rightIconView else { return }
            rightIconView.frame = .init(
                origin: .init(x: self.bounds.maxX - self.layoutMargins.right - (self.spaceBetweenTitlesAndImage * 2), y: rightIconView.frame.origin.y),
                size: self.layout.rightIconSize
            )
            rightIconView.center.y = self.bounds.midY
        }
        
        let layoutTitleCenteredCompact = { [weak self] in
            guard let self = self else { return }
            guard let titleLabel = self.titleLabel else { return }
            titleLabel.textAlignment = .center
            titleLabel.layoutDynamicHeight(width: self.titlesCompactWidth)
            titleLabel.center.x = self.frame.width / 2
        }
        
        let layoutTitleCenteredFullWidth = { [weak self] in
            guard let self = self else { return }
            guard let titleLabel = self.titleLabel else { return }
            titleLabel.textAlignment = .center
            titleLabel.layoutDynamicHeight(width: self.titlesFullWidth)
            titleLabel.center.x = self.frame.width / 2
        }
        
        let layoutTitleLeadingFullWidth = { [weak self] in
            guard let self = self else { return }
            guard let titleLabel = self.titleLabel else { return }
            guard let leftIconView = self.leftIconView else { return }
            let rtl = self.effectiveUserInterfaceLayoutDirection == .rightToLeft
            titleLabel.textAlignment = rtl ? .right : .left
            titleLabel.layoutDynamicHeight(width: self.titlesFullWidth)
            titleLabel.frame.origin.x = self.layoutMargins.left + leftIconView.frame.width + self.spaceBetweenTitlesAndImage
        }
        
        let layoutSubtitle = { [weak self] in
            guard let self = self else { return }
            guard let titleLabel = self.titleLabel else { return }
            guard let subtitleLabel = self.subtitleLabel else { return }
            subtitleLabel.textAlignment = titleLabel.textAlignment
            subtitleLabel.layoutDynamicHeight(width: titleLabel.frame.width)
            subtitleLabel.frame.origin.x = titleLabel.frame.origin.x
        }
        
        let layoutTitleSubtitleByVertical = { [weak self] in
            guard let self = self else { return }
            guard let titleLabel = self.titleLabel else { return }
            guard let subtitleLabel = self.subtitleLabel else {
                titleLabel.center.y = self.bounds.midY
                return
            }
            let allHeight = titleLabel.frame.height + subtitleLabel.frame.height + self.spaceBetweenTitles
            titleLabel.frame.origin.y = (self.frame.height - allHeight) / 2
            subtitleLabel.frame.origin.y = titleLabel.frame.maxY + self.spaceBetweenTitles
        }
        
        switch layout {
        case .iconTitleMessageCentered:
            layoutLeftIcon()
            layoutRightIcon()
            layoutTitleCenteredCompact()
            layoutSubtitle()
        case .iconTitleMessageLeading:
            layoutLeftIcon()
            layoutRightIcon()
            layoutTitleLeadingFullWidth()
            layoutSubtitle()
        case .iconTitleCentered:
            layoutLeftIcon()
            layoutRightIcon()
            titleLabel?.numberOfLines = (hasRightIcon && hasLeftIcon && !hasSubtitle) ? 2 : 1
            layoutTitleCenteredCompact()
            layoutSubtitle()
        case .iconTitleLeading:
            layoutLeftIcon()
            layoutRightIcon()
            titleLabel?.numberOfLines = 2
            layoutTitleLeadingFullWidth()
        case .title:
            titleLabel?.numberOfLines = 2
            layoutTitleCenteredFullWidth()
        case .titleMessage:
            layoutTitleCenteredFullWidth()
            layoutSubtitle()
        }
        
        layoutTitleSubtitleByVertical()
    }
    
    // MARK: - Models
    enum ToastState {
        case prepare(_ from: KBFloatingToastDirection)
        case visible(_ from: KBFloatingToastDirection)
    }
    
    enum ToastLayout {
        case iconTitleMessageCentered
        case iconTitleMessageLeading
        case iconTitleCentered
        case iconTitleLeading
        case title
        case titleMessage
    }
}

#endif

extension UILabel {
    func layoutDynamicHeight(width: CGFloat) {
        layoutDynamicHeight(x: frame.origin.x, y: frame.origin.y, width: width)
    }
    
    func layoutDynamicHeight(x: CGFloat, y: CGFloat, width: CGFloat) {
        frame = CGRect.init(x: x, y: y, width: width, height: frame.height)
        sizeToFit()
        if frame.width != width {
            frame = .init(x: x, y: y, width: width, height: frame.height)
        }
    }
}
