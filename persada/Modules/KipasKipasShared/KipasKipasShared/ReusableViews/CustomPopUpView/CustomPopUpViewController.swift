import UIKit

public protocol CustomPopUpViewControllerDelegate: AnyObject {
    func didSelectOK()
}

public class CustomPopUpViewController: UIViewController {
    @IBOutlet public weak var mainStackView: UIStackView!
    @IBOutlet public weak var textStackView: UIStackView!
    @IBOutlet public weak var actionStackView: UIStackView!
    @IBOutlet public weak var okButton: UIButton!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var descLabel: UILabel!
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var iconImageHeightConstraint: NSLayoutConstraint!
    
    public weak var delegate: CustomPopUpViewControllerDelegate?
    
    public var handleTapOKButton: (() -> Void)?
    public var handleTapCancelButton: (() -> Void)?
    private var titleMessage: String = ""
    private var descriptionMessage: String = ""
    private var withOption: Bool = false
    private var cancelBtnTitle: String = ""
    private var okBtnTitle: String = ""
    private var isHideIcon = false
    private var iconHeight: CGFloat = 0.0
    private var okBtnBgColor: UIColor = .warning
    private var iconImage: UIImage?
    private var actionStackAxis: NSLayoutConstraint.Axis = .horizontal
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleMessage
        descLabel.isHidden = descriptionMessage == ""
        descLabel.text = descriptionMessage
        cancelButton.isHidden = !withOption
        cancelButton.setTitle(cancelBtnTitle, for: .normal)
        cancelButton.titleLabel?.font = .roboto(.bold, size: 14)
        iconImageView.isHidden = isHideIcon || iconImage == .emptyProfilePhoto
        iconImageView.image = iconImage
        iconImageHeightConstraint.constant = isHideIcon ? 0 : iconImage == .emptyProfilePhoto ? 0 : iconHeight
        okButton.titleLabel?.font = .roboto(.bold, size: 14)
        okButton.setTitle(okBtnTitle, for: .normal)
        okButton.backgroundColor = .primary
        okButton.layer.cornerRadius = 8
        actionStackView.axis = actionStackAxis
        mainStackView.layer.cornerRadius = 20
        
        if actionStackAxis == .vertical {
            actionStackView.reverseSubviewsZIndex()
        }
    }
    
    public init(
        title: String = "",
        description: String = "",
        iconImage: UIImage? = UIImage(named: "empty-profile-photo"),
        iconHeight: CGFloat = 35,
        withOption: Bool = false,
        cancelBtnTitle: String = "Batalkan",
        okBtnTitle: String = "OK",
        isHideIcon: Bool = false,
        okBtnBgColor: UIColor = .warning,
        actionStackAxis: NSLayoutConstraint.Axis = .horizontal
    ) {
        self.titleMessage = title
        self.descriptionMessage = description
        self.withOption = withOption
        self.cancelBtnTitle = cancelBtnTitle
        self.okBtnTitle = okBtnTitle
        self.isHideIcon = isHideIcon
        self.iconHeight = iconHeight
        self.iconImage = iconImage
        self.okBtnBgColor = okBtnBgColor
        self.actionStackAxis = actionStackAxis
        super.init(nibName: "CustomPopUpViewController", bundle: Bundle(for: CustomPopUpViewController.self))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didClickOKButton(_ sender: Any) {
        dismiss(animated: false) {
            self.handleTapOKButton?()
            self.delegate?.didSelectOK()
        }
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        dismiss(animated: false, completion: handleTapCancelButton)
    }
}

private extension UIStackView {
    func reverseSubviewsZIndex(setNeedsLayout: Bool = true) {
        let stackedViews = self.arrangedSubviews
        
        stackedViews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        stackedViews.reversed().forEach(addSubview(_:))
        stackedViews.reversed().forEach(addArrangedSubview(_:))
        
        if setNeedsLayout {
            stackedViews.forEach { $0.setNeedsLayout() }
        }
    }
}
