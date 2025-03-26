import UIKit
import KipasKipasShared
import KipasKipasNotification

protocol SystemSettingTypesViewDelegate: AnyObject {
    func didTapClose()
    func didSwitch(types: String, isOn: Bool)
}

class SystemSettingTypesView: UIView {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var actionSwitch: UISwitch!
    @IBOutlet weak var closeIconImageView: UIImageView!
    
    weak var delegate: SystemSettingTypesViewDelegate?
    var types: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func setupComponent() {
        closeIconImageView.onTap { [weak self] in
            self?.delegate?.didTapClose()
        }
        setupOnTap()
    }
    
    func setupOnTap() {
        actionSwitch.addTarget(self, action: #selector(didSwitchTypes), for: .valueChanged)
    }
    
    @objc private func didSwitchTypes(sender: UISwitch) {
        delegate?.didSwitch(types: types, isOn: sender.isOn)
    }
}

extension SystemSettingTypesView {
    func setupComponentBy(_ types: String) {
        self.types = types
        switch types {
        case "hotroom":
            typeTitleLabel.text = "Sosial"
            typeImageView.image = .iconSosialSolidBlack
            subtitleLabel.text = "Dapatkan info terbaru seputar konten update di sosial feed Kipaskipas"
        case "live":
            typeTitleLabel.text = "Live"
            typeImageView.image = .iconLiveSolidBlack
            subtitleLabel.text = "Informasi seputar LIVE streaming di Kipaskipas"
        case "account":
            typeTitleLabel.text = "Akun Update"
            typeImageView.image = .iconUpdateSolidBlack
            subtitleLabel.text = "Dapatkan informasi terkait akun kamu di Kipaskipas"
        default:
            break
        }
    }
    
    func setupSwitch(types: String, item: NotificationPreferencesItem) {
        print("[AZMI] -", item)
        switch types {
        case "hotroom":
            actionSwitch.isOn = item.socialmedia
        case "live":
            actionSwitch.isOn = item.socialMediaLive
        case "account":
            actionSwitch.isOn = item.socialMediaAccount
        default:
            break
        }
    }
}

//protocol SystemSettingTypesViewDelegate {
//    func didTapClose()
//    func didSwitch(types: String, isOn: Bool)
//}
//
//class SystemSettingTypesView: UIView {
//    
//    var delegate: SystemSettingTypesViewDelegate?
//    
//    private(set) lazy var closeButton: UIButton = UIButton()
//    private(set) lazy var typesImage: UIImageView = UIImageView()
//    private(set) lazy var titleLabel: UILabel = UILabel()
//    private(set) lazy var subtitleLabel: UILabel = UILabel()
//    private(set) lazy var dividerView: UIView = UIView()
//    private(set) lazy var typesLabel: UILabel = UILabel()
//    private(set) lazy var typesSwitch: UISwitch = UISwitch()
//    private(set) lazy var typesView: UIView = UIView()
//    private(set) lazy var typesStack: UIStackView = UIStackView()
//    private(set) lazy var containerView: UIView = UIView()
//    private(set) lazy var typesImageContainetView = UIView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        configUI()
//    }
//}
//
//extension SystemSettingTypesView {
//    func setupComponentBy(_ type: String) {
//        switch type {
//        case "hotroom":
//            titleLabel.text = "Sosial"
//            typesImage.image = .iconNewsPaperGray
//            subtitleLabel.text = "Dapatkan info terbaru seputar konten update di sosial feed Kipaskipas"
//        case "live":
//            titleLabel.text = "Live"
//            typesImage.image = .iconVideo
//            subtitleLabel.text = "Informasi seputar LIVE streaming di Kipaskipas"
//        case "account":
//            titleLabel.text = "Akun Update"
//            typesImage.image = .iconArrowUpGray
//            subtitleLabel.text = "Dapatkan informasi terkait akun kamu di Kipaskipas"
//        default:
//            break
//        }
//    }
//}
//
//// MARK: - Internal Helper
//extension SystemSettingTypesView {
//    func `switch`(types: String, isOn: Bool, animated: Bool) {
////        switch types {
////        case "hotroom": break
////        case "live": break
////        case "account": break
////            typesSwitch.setOn(isOn, animated: animated)
////        }
//    }
//}
//
//// MARK: - Private Helper
//private extension SystemSettingTypesView {
//    func configUI() {
//        
//        configureCloseButton()
//        configureTypesStack()
//        configureDivider()
//        configureContainerStack()
//        
//        setupOnTap()
//    }
//    
//    func configureCloseButton() {
//        addSubview(closeButton)
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.contentMode = .scaleAspectFill
//        closeButton.clipsToBounds = true
//        closeButton.accessibilityIdentifier = "closeButton"
//        closeButton.isUserInteractionEnabled = true
//        closeButton.setImage(.iconCircleX?.withTintColor(.black))
//        closeButton.anchors.trailing.equal(anchors.trailing, constant: -16)
//        closeButton.anchors.top.equal(safeAreaLayoutGuide.anchors.top, constant: 14)
//        closeButton.anchors.height.equal(15)
//        closeButton.anchors.width.equal(15)
//        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
//    }
//    
//    func configureTypesStack() {
//        addSubview(typesStack)
//        typesStack.translatesAutoresizingMaskIntoConstraints = false
//        typesStack.axis = .vertical
//        typesStack.distribution = .fill
//        typesStack.alignment = .center
//        typesStack.spacing = 20
//        typesStack.anchors.top.equal(closeButton.anchors.bottom, constant: 8)
//        typesStack.anchors.leading.equal(self.anchors.leading)
//        typesStack.anchors.trailing.equal(self.anchors.trailing)
//        
//        configureTypesImage()
//        configureTitleLabel()
//        configureSubtitleLabel()
//    }
//    func configureTypesImage() {
//        typesImageContainetView.backgroundColor = .whiteSmoke
//        typesImageContainetView.layer.cornerRadius = 72 / 2
//        typesImageContainetView.anchors.width.equal(72)
//        typesImageContainetView.anchors.height.equal(72)
//        
//        typesImageContainetView.addSubview(typesImage)
//        
//        typesImage.image = .iconNewsPaperGray
//        typesImage.backgroundColor = .whiteSmoke
//        typesImage.contentMode = .scaleAspectFit
//        typesImage.anchors.width.equal(32)
//        typesImage.anchors.height.equal(32)
//        typesImage.anchors.centerX.equal(typesImageContainetView.anchors.centerX)
//        typesImage.anchors.centerY.equal(typesImageContainetView.anchors.centerY)
//        
//        typesStack.addArrangedSubview(typesImageContainetView)
//    }
//    
//    func configureTypesSwitch() {
//        typesStack.addArrangedSubview(typesView)
//        typesView.translatesAutoresizingMaskIntoConstraints = false
//        typesView.addSubviews([typesLabel, typesSwitch])
//        
//        typesSwitch.anchors.top.equal(typesView.anchors.top)
//        typesSwitch.anchors.trailing.equal(typesView.anchors.trailing)
//        typesSwitch.anchors.bottom.equal(typesView.anchors.bottom)
//        
//        typesLabel.anchors.centerY.equal(typesView.anchors.centerY)
//        typesLabel.anchors.leading.equal(typesView.anchors.leading)
//        typesLabel.anchors.trailing.equal(typesSwitch.anchors.leading, constant: -12)
//    }
//    
//    func configureTitleLabel() {
//        typesStack.addArrangedSubview(titleLabel)
//        titleLabel.textColor = .black
//        titleLabel.font = .roboto(.bold, size: 23)
//        titleLabel.numberOfLines = 1
//        titleLabel.textAlignment = .center
//    }
//    
//    func configureSubtitleLabel() {
//        typesStack.addArrangedSubview(subtitleLabel)
//        subtitleLabel.textColor = .grey
//        subtitleLabel.font = .roboto(.medium, size: 14)
//        subtitleLabel.numberOfLines = 0
//        subtitleLabel.textAlignment = .center
//    }
//    
//    func configureDivider() {
//        addSubview(dividerView)
//        dividerView.translatesAutoresizingMaskIntoConstraints = false
//        dividerView.backgroundColor = .placeholder
//        dividerView.anchors.leading.equal(anchors.leading, constant: 24)
//        dividerView.anchors.trailing.equal(anchors.trailing, constant: -24)
//        dividerView.anchors.top.equal(typesStack.anchors.bottom, constant: 20)
//        dividerView.anchors.height.equal(1)
//    }
//    
//    func configureContainerStack() {
//        addSubview(containerView)
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        
//        containerView.addSubviews([typesView])
//    
//        typesView.anchors.leading.equal(containerView.anchors.leading)
//        typesView.anchors.trailing.equal(containerView.anchors.trailing)
//        typesView.anchors.top.equal(containerView.anchors.top)
//        
//        
//        containerView.anchors.leading.equal(anchors.leading, constant: 16)
//        containerView.anchors.trailing.equal(anchors.trailing, constant: -16)
//        containerView.anchors.top.equal(dividerView.anchors.bottom, constant: 16)
//        containerView.anchors.bottom.equal(anchors.bottom, constant: -16)
//    }
//    
//    func setupOnTap() {
//
//        typesSwitch.addTarget(self, action: #selector(didSwitchTypes), for: .valueChanged)
//    }
//    
//    
//    @objc private func handleClose() {
//        self.delegate?.didTapClose()
//    }
//    
//    @objc private func didSwitchTypes(sender: UISwitch) {
////        delegate?.didSwitch(types: , isOn: sender.isOn)
//    }
//}
