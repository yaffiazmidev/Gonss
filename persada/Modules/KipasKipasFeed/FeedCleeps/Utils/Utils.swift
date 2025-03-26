//
//  Utils.swift
//  KKCleepsApp
//
//  Created by PT.Koanba on 12/05/22.
//

import Foundation
import UIKit
import Kingfisher

public var ossPerformance = "?x-oss-process=image/format,jpg/interlace,1/resize,w_"
public var ossBackgroundImageColor = "?x-oss-process=image/average-hue"
public var ossPerformancePng = "?x-oss-process=image/format,png/resize,w_"


class MoneyHelper {
    private init() {}
    
    static func toMoney(amount: Double?) -> String {
        guard let amount = amount else {
            return "Rp 0"
        }

        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return money
    }
}


extension String {
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    static func get(_ key: StringEnum) -> String {
        return key.rawValue.localized()
    }

    static func get(_ key: StringEnum, _ arguments: CVarArg...) -> String {
        return withVaList(arguments, { (params) -> String in
            return NSString(format: key.rawValue.localized(), arguments: params) as String
        })
    }

    func localized(withComment comment: String? = nil) -> String {
        return NSLocalizedString(self, comment: comment ?? "")
    }

    static func get(_ key: AssetEnum) -> String {
        return key.rawValue
    }
}

extension UITableView {
    func dequeueReusableCell<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: AnyObject {
        let identifier = "\(cellClass)"
        if let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T {
            return cell
        }

        fatalError("Error dequeueing cell")
    }
    
    func registerCell<T>(_ cellClass: T.Type) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: SharedBundle.shared.bundle), forCellReuseIdentifier: identifier)
    }
}

extension UIView {
    private typealias Action = (() -> Void)?
    private struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "UIView_tapGesture"
    }

    private var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedObjectKeys.tapGestureRecognizer,
                    newValue,
                    objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
                )
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(
                self,
                &AssociatedObjectKeys.tapGestureRecognizer
                ) as? Action
            return tapGestureRecognizerActionInstance
        }
    }

    public func onTap(action: (() -> Void)?) {
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if let completion = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? () -> Void {
            completion()
        }
    }
}
extension Notification.Name {
    static let updateIsFollowFromFolowingFolower = Notification.Name("updateIsFollowFromFolowingFolower")
    static let showUploadProgressBar = Notification.Name("showUploadProgressBar")
    static let showOnboardingView = Notification.Name("showOnboardingView")
    static let callbackWhenActiveProduct = Notification.Name("callbackWhenActiveProduct")
    static let notifyRemoveDataAfterDelete = Notification.Name("notifyRemoveDataAfterDelete")
    static let notifyUpdateCounterTransaction = Notification.Name("com.kipaskipas.updateCounterTranssaction")
    static let notifyCounterTransaction = Notification.Name("com.kipaskipas.counterTransaction")
    static let notifyUpdateCounterSocial = Notification.Name("com.kipaskipas.updateCounterSocial")
    static let notifyCounterSocial = Notification.Name("com.kipaskipas.counterSocial")
    static let notifyWillEnterForeground = Notification.Name("com.kipaskipas.notifyWillEnterForeground")
    static let notifyWillEnterForegroundFeed = Notification.Name("com.kipaskipas.notifyWillEnterForegroundFeed")
    static let notifyReloadChannelSearch = Notification.Name("com.kipaskipas.reloadChannelSearchContent")
    static let showOnboardingViewAfterDeleteAccount = Notification.Name("showOnboardingViewAfterDeleteAccount")
    static let refreshTokenFailedToComplete = Notification.Name("refreshTokenFailedToComplete")
    static let newsDetailUnivLink = Notification.Name("com.kipaskipas.newsDetailUnivLink")
    static let pushNotifForNewsFeedFeed = Notification.Name(rawValue: "PushNotifForNewsFeedFeed")
    static let pushNotifForNewsId = Notification.Name(rawValue: "PushNotifForNewsID")
    static let pushNotifForLikeFeedId = Notification.Name(rawValue: "PushNotifForLikeFeedID")
    static let pushNotifForCommentId = Notification.Name(rawValue: "PushNotifForCommentID")
    static let pushNotifForLikeCommentId = Notification.Name(rawValue: "PushNotifForLikeCommentID")
    static let pushNotifForSubcommentId = Notification.Name(rawValue: "PushNotifForSubcommentID")
    static let pushNotifForLikeSubcommentId = Notification.Name(rawValue: "PushNotifForLikeSubcommentID")
    static let pushNotifForUserProfileId = Notification.Name(rawValue: "PushNotifForUserProfileID")
    static let pushNotifForWeightAdjustmentId = Notification.Name(rawValue: "PushNotifForWeightAdjustmentID")
    static let pushNotifForBannedProductId = Notification.Name(rawValue: "PushNotifForBannedProductId")
    static let pushNotifForMentionFeedId = Notification.Name(rawValue: "PushNotifForMentionFeedID")
    static let pushNotifForMentionCommentId = Notification.Name(rawValue: "PushNotifForMentionCommentID")
    static let pushNotifForMentionSubcommentId = Notification.Name(rawValue: "PushNotifForMentionSubcommentID")
    static let pushNotifForBuyerShopPaymentPaidId = Notification.Name(rawValue: "PushNotifForBuyerShopPaymentPaidID")
    static let pushNotifForSellerShopPaymentPaidId = Notification.Name(rawValue: "PushNotifForSellerShopPaymentPaidID")
    static let qrNotificationKey = Notification.Name(rawValue: "qrNotificationKey")
    static let handleUpdateExploreContent = NSNotification.Name("handleUpdateExploreContent")
    static let handleUpdateFeed = Notification.Name(rawValue: "com.kipaskipas.updateFeed")
    static let notifyReadyFeedKey = Notification.Name(rawValue: "com.kipaskipas.notifyReadyFeedKey")
    static let clearFeedCleepsData = Notification.Name(rawValue: "com.kipaskipas.clearFeedCleepsData")
    static let shouldResumePlayer = Notification.Name(rawValue: "shouldResumePlayer")
    static let shouldPausePlayer = Notification.Name(rawValue: "shouldPausePlayer")
    static let destroyObserver = Notification.Name(rawValue: "destroyObserver")
}


extension UIView {

    // MARK: - Public Methods

    func anchorFeedCleeps(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func anchorFeedCleeps(top: NSLayoutYAxisAnchor? = nil,
                            left: NSLayoutXAxisAnchor? = nil,
                            bottom: NSLayoutYAxisAnchor? = nil,
                            right: NSLayoutXAxisAnchor? = nil,
                            paddingTop: CGFloat = 0,
                            paddingLeft: CGFloat = 0,
                            paddingBottom: CGFloat = 0,
                            paddingRight: CGFloat = 0,
                            width: CGFloat? = nil,
                            height: CGFloat? = nil) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true

        if let leftAnchor = leftAnchor, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        }
    }

    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func keepCenterAndApplyAnchorPoint(_ point: CGPoint) {
            
            guard layer.anchorPoint != point else { return }
            
            var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
            var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
            
            newPoint = newPoint.applying(transform)
            oldPoint = oldPoint.applying(transform)
            
            var c = layer.position
            c.x -= oldPoint.x
            c.x += newPoint.x
            
            c.y -= oldPoint.y
            c.y += newPoint.y
            
            layer.position = c
            layer.anchorPoint = point
    }
    
    func endFunction(){}
    
    public func addBottomSeparator(margin: CGFloat = 8){
            
            let vw_separator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            vw_separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            self.addSubview(vw_separator)
            
            vw_separator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                    //text_field: Constraint
                    vw_separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
                    self.trailingAnchor.constraint(equalTo: vw_separator.trailingAnchor, constant: margin),
                    self.bottomAnchor.constraint(equalTo: vw_separator.bottomAnchor, constant: 0),
                    vw_separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
            
    }
    
    public func addTopSeparator(margin: CGFloat = 8){
            
            let vw_separator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            vw_separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            self.addSubview(vw_separator)
            
            vw_separator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                    //text_field: Constraint
                    vw_separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
                    self.trailingAnchor.constraint(equalTo: vw_separator.trailingAnchor, constant: margin),
                    self.topAnchor.constraint(equalTo: vw_separator.topAnchor, constant: 0),
                    vw_separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
            
    }
}

extension UILabel {

    func addImageWith(name: String, behindText: Bool) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        let attachmentString = NSAttributedString(attachment: attachment)

        guard let txt = self.text else {
            return
        }

        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }

    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))


        // (Swift 4.1 and 4.0) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
    
    func addDropShadow(color: UIColor = .black) {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2, height: 1)
        self.layer.shadowColor = color.cgColor
        self.layer.shouldRasterize = true

    }
    
    func addDropShadow(color: UIColor = .black, radius: CGFloat, opacity: Float, offset: CGSize = .init(width: 0, height: 0)) {
        layer.masksToBounds = false
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shouldRasterize = true
    }

    
    convenience public init(text: String? = nil, font: UIFont? = UIFont.systemFont(ofSize: 14), textColor: UIColor = .black, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}

class PrimaryButton: UIButton {
    
    var titleFont: UIFont? {
        get { return titleLabel?.font }
        set { titleLabel?.font = newValue }
    }
    
    struct ButtonState {
        var state: UIControl.State
        var title: String?
        var image: UIImage?
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(color: UIColor = UIColor.primary, textColor: UIColor = .white, font: UIFont = .Roboto(.bold, size: 16)) {
        self.layer.cornerRadius = 8
        self.backgroundColor = color
        self.titleLabel?.font = font
        self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.setTitleColor(textColor, for: .normal)
        
    }
    
    private (set) var buttonStates: [ButtonState] = []
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = self.titleColor(for: .normal)
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraints([xCenterConstraint, yCenterConstraint])
        return activityIndicator
    }()
    
    func showLoading() {
        activityIndicator.startAnimating()
        var buttonStates: [ButtonState] = []
        for state in [UIControl.State.disabled] {
            let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
            buttonStates.append(buttonState)
            setImage(UIImage(), for: state)
        }
        self.buttonStates = buttonStates
        isEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        for buttonState in buttonStates {
            setImage(buttonState.image, for: buttonState.state)
        }
        isEnabled = true
    }
    
}

extension UIButton {
    private func actionHandler(action:(() -> Void)? = nil) {
        struct __ { static var action :(() -> Void)? }
        if action != nil { __.action = action }
        else { __.action?() }
    }
    @objc private func triggerActionHandler() {
        self.actionHandler()
    }
    func actionHandler(controlEvents control :UIControl.Event, ForAction action:@escaping () -> Void) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
    
    var isValid: Bool {
        get {
            return isEnabled && backgroundColor == .primary
        }
        set {
            backgroundColor = newValue ? .primary : .orangeLowTint
            isEnabled = newValue
        }
    }
    
    var isEmpty: Bool {
        get {
            return isEnabled && backgroundColor == .clear
        }
        set {
            backgroundColor = .clear
            isEnabled = newValue
        }
    }
    
    func setupButton(color: UIColor = UIColor.primary, textColor: UIColor = .white, font: UIFont = .Roboto(.bold, size: 16)) {
                    self.layer.cornerRadius = 8
                    self.backgroundColor = color
                    self.titleLabel?.font = font
//                    self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
                    self.setTitleColor(textColor, for: .normal)
    
            }

    convenience public init(title: String, titleColor: UIColor, font: UIFont = .systemFont(ofSize: 14), backgroundColor: UIColor = .clear, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        
        self.backgroundColor = backgroundColor
        if let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    convenience public init(image: UIImage, tintColor: UIColor? = nil, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        if tintColor == nil {
            setImage(image, for: .normal)
        } else {
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = tintColor
        }
        
        if let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
}

class ButtonIconImage: UIView {
    
    // MARK: - Public Property
    
    lazy var previewImage: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "Unionplus")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.backgroundColor = .red
        image.layer.masksToBounds = false
        image.layer.cornerRadius = 10
        return image
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleTappedStoryButton), for: .touchUpInside)
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 25
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    var handler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button)
        addSubview(previewImage)
        
        button.fillSuperviewSafeAreaLayoutGuideFeedCleeps()
        previewImage.anchorFeedCleeps(top: nil, left: nil, bottom: button.bottomAnchor, right: button.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTappedStoryButton() {
        self.handler?()
    }
    
    
}

extension UIButton {
        //MARK:- Animate check mark
        func checkboxAnimation(closure: @escaping () -> Void){
                guard let image = self.imageView else {return}
                
                UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                        image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        
                }) { (success) in
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                                self.isSelected = !self.isSelected
                                //to-do
                                closure()
                                image.transform = .identity
                        }, completion: nil)
                }
                
        }
}

extension UIView {
    func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           layer.mask = mask
       }
    
    func roundBottom(radius:CGFloat = 8){
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            if #available(iOS 11.0, *) {
                self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
        }
}

public struct AnchoredConstraints {
    public var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}


@available(iOS 9.0, *)
public enum AnchorFeedCleeps {
    case top(_ top: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case leading(_ leading: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case bottom(_ bottom: NSLayoutYAxisAnchor, constant: CGFloat = 0)
    case trailing(_ trailing: NSLayoutXAxisAnchor, constant: CGFloat = 0)
    case height(_ constant: CGFloat)
    case width(_ constant: CGFloat)
}

// Reference Video: https://youtu.be/iqpAP7s3b-8
@available(iOS 9.0, *)
extension UIView {
    
    @discardableResult
    open func anchorFeedCleeps(_ anchors: AnchorFeedCleeps...) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchors.forEach { anchor in
            switch anchor {
            case .top(let anchor, let constant):
                anchoredConstraints.top = topAnchor.constraint(equalTo: anchor, constant: constant)
            case .leading(let anchor, let constant):
                anchoredConstraints.leading = leadingAnchor.constraint(equalTo: anchor, constant: constant)
            case .bottom(let anchor, let constant):
                anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: anchor, constant: -constant)
            case .trailing(let anchor, let constant):
                anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: anchor, constant: -constant)
            case .height(let constant):
                if constant > 0 {
                    anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
                }
            case .width(let constant):
                if constant > 0 {
                    anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
                }
            }
        }
        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing,
         anchoredConstraints.width,
         anchoredConstraints.height].forEach {
            $0?.isActive = true
        }
        return anchoredConstraints
    }
    
    @discardableResult
    open func anchorFeedCleeps(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        
        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }
        
        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }
        
        if size.width != 0 {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }
        
        if size.height != 0 {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }
        
//        guard self.window != nil && self.frame.size == .zero else {
            print("MEMIssue,",
                  "constraints:", self.constraints,
                  "window nil:", self.window == nil,
                  "frame:", self.frame,
                  "superView:", self.superview as Any,
                  "memory of self:", unsafeBitCast(self, to: UIView.self),
                  "top anchor active", anchoredConstraints.top?.isActive,
                  "leading anchor active", anchoredConstraints.leading?.isActive,
                  "bottom anchor active", anchoredConstraints.bottom?.isActive,
                  "trailing anchor active", anchoredConstraints.trailing?.isActive,
                  "width anchor active", anchoredConstraints.width?.isActive,
                  "height anchor active", anchoredConstraints.height?.isActive
            )
            
//            return anchoredConstraints
//        }
        
        anchoredConstraints.top?.isActive = true
        anchoredConstraints.leading?.isActive = true
        anchoredConstraints.bottom?.isActive = true
        anchoredConstraints.trailing?.isActive = true
        anchoredConstraints.width?.isActive = true
        anchoredConstraints.height?.isActive = true
        
        return anchoredConstraints
    }
    
    @discardableResult
    open func fillSuperviewFeedCleeps(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        let anchoredConstraints = AnchoredConstraints()
        guard let superviewTopAnchor = superview?.topAnchor,
            let superviewBottomAnchor = superview?.bottomAnchor,
            let superviewLeadingAnchor = superview?.leadingAnchor,
            let superviewTrailingAnchor = superview?.trailingAnchor else {
                return anchoredConstraints
        }
        
        return anchorFeedCleeps(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
    }
    
    @discardableResult
    open func fillSuperviewSafeAreaLayoutGuideFeedCleeps(padding: UIEdgeInsets = .zero) -> AnchoredConstraints {
        let anchoredConstraints = AnchoredConstraints()
        if #available(iOS 11.0, *) {
            guard let superviewTopAnchor = superview?.safeAreaLayoutGuide.topAnchor,
                let superviewBottomAnchor = superview?.safeAreaLayoutGuide.bottomAnchor,
                let superviewLeadingAnchor = superview?.safeAreaLayoutGuide.leadingAnchor,
                let superviewTrailingAnchor = superview?.safeAreaLayoutGuide.trailingAnchor else {
                    return anchoredConstraints
            }
            return anchorFeedCleeps(top: superviewTopAnchor, leading: superviewLeadingAnchor, bottom: superviewBottomAnchor, trailing: superviewTrailingAnchor, padding: padding)
            
        } else {
            return anchoredConstraints
        }
    }
    
    open func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
        
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    open func centerXTo(_ anchor: NSLayoutXAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    open func centerYTo(_ anchor: NSLayoutYAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).isActive = true
    }
    
    open func centerXToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }
    }
    
    open func centerYToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }
    }
    
    @discardableResult
    open func constrainHeightFeedCleeps(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.height = heightAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.height?.isActive = true
        return anchoredConstraints
    }
    
    @discardableResult
    open func constrainWidth(_ constant: CGFloat) -> AnchoredConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()
        anchoredConstraints.width = widthAnchor.constraint(equalToConstant: constant)
        anchoredConstraints.width?.isActive = true
        return anchoredConstraints
    }
    
    open func setupShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
    
    convenience public init(backgroundColor: UIColor = .clear) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
}

@available(iOS 9.0, *)
extension UIView {
    
    fileprivate func _stack(_ axis: NSLayoutConstraint.Axis = .vertical, views: [UIView], spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = alignment
        stackView.distribution = distribution
        addSubview(stackView)
        stackView.fillSuperviewFeedCleeps()
        return stackView
    }
    
    @discardableResult
    open func stack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        return _stack(.vertical, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    @discardableResult
    open func hstack(_ views: UIView..., spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) -> UIStackView {
        return _stack(.horizontal, views: views, spacing: spacing, alignment: alignment, distribution: distribution)
    }
    
    @discardableResult
    open func withSize<T: UIView>(_ size: CGSize) -> T {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        return self as! T
    }
    
    @discardableResult
    open func withHeight(_ height: CGFloat) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    open func withWidth(_ width: CGFloat) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    func withBorder<T: UIView>(width: CGFloat, color: UIColor) -> T {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        return self as! T
    }
}

extension UIEdgeInsets {
    static public func allSides(_ side: CGFloat) -> UIEdgeInsets {
        return .init(top: side, left: side, bottom: side, right: side)
    }
}

extension UIImageView {
    convenience public init(image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFill) {
        self.init(image: image)
        self.contentMode = contentMode
        self.clipsToBounds = true
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toString(format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "id_ID")
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.day = 1
        return cal.date(byAdding: components, to: self.startOfDay)!.addingTimeInterval(-1)
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
}

extension UIImageView {
    
    func loadImageCallback(at urlPath: String, _ size: OSSSizeImage = .w576, completion: @escaping () -> (), errorCompletion: @escaping (String) -> ()) {

        if(urlPath == "") {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlPath + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        let placeholderImage = UIImage(named: .get(.empty))
        self.kf.indicatorType = .activity
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
                completion()
            }
            .onFailure { error in
                errorCompletion(error.errorDescription ?? "unknown error")
            }
            .set(to: self)
    }
    
    func loadImageWithoutOSS(at urlPath : String) {

        if(urlPath == "") {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        guard let url = URL(string: urlPath) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        let processor = DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))
                     |> RoundCornerImageProcessor(cornerRadius: 8)
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        let placeholderImage = UIImage(named: .get(.empty))
        self.kf.indicatorType = .activity        
        
        KF.url(url)
            .diskCacheExpiration(.seconds(600))
            .memoryCacheExpiration(.seconds(600))
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.setProcessor(processor)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
    
    func loadImage(at urlPath: String, _ size: OSSSizeImage = .w576, emptyImageName: String = .get(.empty)) {
        //print("****** loadImage",urlPath)
        
        if(urlPath == "") {
            self.image = UIImage(named: emptyImageName)
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = UIImage(named: emptyImageName)
            return
        }
        
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlPath + ossPerformance + size.rawValue
            
            // if .png, exclude "jpg and interlace,1" parameter, because it will make .png not transparent
            if(urlPath.lowercased().contains(".png")){
                urlValid = urlPath + ossPerformancePng + size.rawValue
            }
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = UIImage(named: emptyImageName)
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        
        let placeholderImage = UIImage(named: emptyImageName)
        self.kf.indicatorType = .activity
        
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
    
    func loadImage(at urlPath: String, low urlLowResPath : String, _ size: OSSSizeImage = .w576, _ sizeLowRes: OSSSizeImage = .w576) {
        
        if(urlPath == "") {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlPath + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        var lowUrlValid = urlLowResPath
        if urlLowResPath.containsIgnoringCase(find: ossPerformance) == false {
            lowUrlValid = urlLowResPath + ossPerformance + sizeLowRes.rawValue
        }
        
        guard let lowUrl = URL(string: lowUrlValid) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        
        
        let placeholderImage = UIImage(named: .get(.empty))
        self.kf.indicatorType = .activity
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.cacheMemoryOnly()
            .lowDataModeSource(.network(lowUrl))
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
    
    //Responsiblity: to holds the List of Activity Indicator for ImageView
    //DataSource: UI-Level
    struct ActivityIndicator {
            static var isEnabled = false
            static var style = UIActivityIndicatorView.Style.whiteLarge
            static var view = UIActivityIndicatorView(style: .whiteLarge)
    }
    
    //MARK: Public Vars
    public var isActivityEnabled: Bool {
            get {
                    guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
                            return false
                    }
                    return value
            }
            set(updatedValue) {
                    objc_setAssociatedObject(self, &ActivityIndicator.isEnabled, updatedValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
    }
    public var activityStyle: UIActivityIndicatorView.Style {
            get{
                    guard let value = objc_getAssociatedObject(self, &ActivityIndicator.style) as? UIActivityIndicatorView.Style else {
                            return .whiteLarge
                    }
                    return value
            }
            set(updatedValue) {
                    objc_setAssociatedObject(self, &ActivityIndicator.style, updatedValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
    }
    public var activityIndicator: UIActivityIndicatorView {
            get {
                    guard let value = objc_getAssociatedObject(self, &ActivityIndicator.view) as? UIActivityIndicatorView else {
                            return UIActivityIndicatorView(style: .whiteLarge)
                    }
                    return value
            }
            set(updatedValue) {
                    let activityView = updatedValue
                    activityView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                    activityView.hidesWhenStopped = true
                    objc_setAssociatedObject(self, &ActivityIndicator.view, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
    }
    
    //MARK: - Private methods
    func showActivityIndicator() {
            if isActivityEnabled {
                    DispatchQueue.main.async {
                        self.backgroundColor = .black
                            self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                            if !self.subviews.contains(self.activityIndicator) {
                                    self.addSubview(self.activityIndicator)
                            }
                            self.activityIndicator.startAnimating()
                    }
            }
    }
    
    func hideActivityIndicator() {
            if isActivityEnabled {
                    DispatchQueue.main.async {
                            self.backgroundColor = UIColor.white
                            self.subviews.forEach({ (view) in
                                    if let av = view as? UIActivityIndicatorView {
                                            av.stopAnimating()
                                    }
                            })
                    }
            }
    }

    func roundCornersForAspectFit(radius: CGFloat)
    {
        if let image = self.image {

            //calculate drawingRect
            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height

            var drawingRect: CGRect = self.bounds

            if boundsScale > imageScale {
                drawingRect.size.width =  drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

}

extension UIViewController {
    func bindNavigationBar(_ title: String? = "", _ isBackPopOrDismiss: Bool = true, icon: String = .get(.iconClose)) {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(UIImage(named: "iconClose"), for: UIControl.State())
        if isBackPopOrDismiss {
            btnLeftMenu.addTarget(self, action: #selector(onClickBackWithPop), for: .touchUpInside)
        } else {
            btnLeftMenu.addTarget(self, action: #selector(onClickBackWithDimiss), for: .touchUpInside)
        }
        
        btnLeftMenu.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.title = title ?? ""
    }
    
    func bindNavigationRightBar(_ title: String? = "", _ isBackPopOrDismiss: Bool = true, icon: String = .get(.iconClose)) {
        let btnRightBar: UIButton = UIButton()
        btnRightBar.setImage(UIImage(named: icon), for: UIControl.State())
        if isBackPopOrDismiss {
            btnRightBar.addTarget(self, action: #selector(onClickBackWithPop), for: .touchUpInside)
        } else {
            btnRightBar.addTarget(self, action: #selector(onClickBackWithDimiss), for: .touchUpInside)
        }
        
        btnRightBar.frame = CGRect(x: 0, y: 0, width: 33/2, height: 27/2)
        let barButton = UIBarButtonItem(customView: btnRightBar)
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.title = title ?? ""
    }
    
    @objc private func onClickBackWithPop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func onClickBackWithDimiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension UIImageView {
    
    func setImage(with urlString: String?) {
        guard let url = URL(string: urlString ?? "") else {
            image = UIImage(named: "empty")
            return
        }
        
        self.kf.setImage(with: url)
    }
    
    func setImageOSS(with urlString: String?, _ size: OSSSizeImage, placeholder: String = "empty") {
        guard let urlString = urlString else {
            image = UIImage(named: placeholder)
            return
        }
        
        var urlOSS: String {
            urlString.containsIgnoringCase(find: ossPerformance) ? urlString : "\(urlString)\(ossPerformance)\(size.rawValue)"
        }
        
        
        guard let url = URL(string: urlOSS) else {
            image = UIImage(named: placeholder)
            return
        }
        
        self.kf.setImage(with: url)
    }
}

extension UIImageView {
    func loadImageWith(url: String, _ size: OSSSizeImage = .w576, emptyImage: UIImage?) {
        //print("****** loadImage",urlPath)
        
        if(url == "") {
            self.image = emptyImage
            return
        }
        
        var urlValid = url
        if url.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = url + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = emptyImage
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        
        let placeholderImage = emptyImage
        self.kf.indicatorType = .activity
        
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
}
