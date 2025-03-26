import UIKit
import KipasKipasShared
import KipasKipasVerificationIdentity

protocol VerifyIdentityUploadStatusViewDelegate: AnyObject {
    func didClickConfirmButton()
}

class VerifyIdentityUploadStatusView: UIView {

    @IBOutlet weak var bodLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var identityTypeLabel: UILabel!
    @IBOutlet weak var failedVerifyTitleLabel: UILabel!
    @IBOutlet weak var titleIconImageView: UIImageView!
    @IBOutlet weak var failedVerifyReasonLabel: UILabel!
    @IBOutlet weak var identityContainerStack: UIStackView!
    @IBOutlet weak var failedVerifyContainerStack: UIStackView!
    @IBOutlet weak var getNotifyRadioButton: KKRadioButtonView!
    @IBOutlet weak var sendIdentityRadioButton: KKRadioButtonView!
    @IBOutlet weak var waitingVerifyRadioButton: KKRadioButtonView!
    @IBOutlet weak var confirmButton: KKLoadingButton!
    
    @IBOutlet weak var waitingVerifyDescLabel: UILabel!
    @IBOutlet weak var emailStatusIconImageView: UIImageView!
    @IBOutlet weak var phoneNumberStatusIconImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var changeEmailLabel: UILabel!
    @IBOutlet weak var changePhoneNumberLabel: UILabel!
    @IBOutlet weak var emailContainerStack: UIStackView!
    @IBOutlet weak var phoneNumberContainerStack: UIStackView!
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    weak var delegate: VerifyIdentityUploadStatusViewDelegate?
    
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
        configureUI()
    }
    
    func setupView(statusItem: VerifyIdentityStatusItem) {
        let status = statusItem.verificationStatusType
        bodLabel.text = statusItem.birthDate ?? "-"
        identityTypeLabel.text = statusItem.type ?? "-"
        fullnameLabel.text = statusItem.accountName?.maskName() ?? "-"
        
        setupTitleAndSubtitle(by: status)
        setupConfirmButton(with: statusItem)
        setupRadioButtons(by: status)
        
        switch status {
        case .unverified, .revision, .rejected:
            
            if statusItem.verificationStatusType == .revision {
                confirmButton.setTitle("Ulangi proses verifikasi")
                emailLabel.text = statusItem.email
                phoneNumberLabel.text = statusItem.phone
                let isShowRevisionEmailAndPhone = !statusItem.isEmailRevision && !statusItem.isPhoneNumberRevision
                emailContainerStack.isHidden = isShowRevisionEmailAndPhone
                phoneNumberContainerStack.isHidden = isShowRevisionEmailAndPhone
                
                if statusItem.isEmailRevision {
                    changeEmailLabel.isHidden = false
                    emailStatusIconImageView.image = .iconCircleCloseFillRed
                    confirmButton.isEnabled = false
                } else {
                    confirmButton.isEnabled = true
                }
                
                if statusItem.isPhoneNumberRevision {
                    changePhoneNumberLabel.isHidden = false
                    phoneNumberStatusIconImageView.image = .iconCircleCloseFillRed
                } else {
                    confirmButton.isEnabled = true
                }
            }
            
            titleIconImageView.image = .iconCircleCloseFillRed
            failedVerifyTitleLabel.text = statusItem.reasonCategory
            failedVerifyReasonLabel.text = statusItem.reason
            failedVerifyContainerStack.isHidden = false
            identityContainerStack.isHidden = true
        case .uploaded:
            titleIconImageView.image = .iconClockFillGray
            identityContainerStack.isHidden = true
            failedVerifyContainerStack.isHidden = true
        case .checking, .validating, .waiting_verification:
            titleIconImageView.image = .iconClockFillGray
            failedVerifyContainerStack.isHidden = true
            identityContainerStack.isHidden = false
            waitingVerifyDescLabel.isHidden = false
        case .verified:
            titleIconImageView.image = .iconCircleCheckGreen
            failedVerifyContainerStack.isHidden = true
            identityContainerStack.isHidden = false
        }
    }
    
    @IBAction func didClickConfirmButton(_ sender: Any) {
        delegate?.didClickConfirmButton()
    }
}

extension VerifyIdentityUploadStatusView {
    
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        identityContainerStack.isHidden = true
        failedVerifyContainerStack.isHidden = true
        emailContainerStack.isHidden = true
        phoneNumberContainerStack.isHidden = true
        changeEmailLabel.isHidden = true
        changePhoneNumberLabel.isHidden = true
        
        setupDefaultAllProcessRadioButton(isActive: false, activeColor: .placeholder)
        configureConfirmButton()
    }
    
    private func configureConfirmButton() {
        confirmButton.setTitle("Saya mengerti")
        confirmButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        confirmButton.indicatorPosition = .right
        confirmButton.setBackgroundColor(.gradientStoryOne, for: .normal)
        confirmButton.setBackgroundColor(.gradientStoryOne, for: .disabled)
        confirmButton.indicator.color = .white
        confirmButton.titleLabel?.font = .roboto(.medium, size: 16)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitleColor(.white, for: .disabled)
        confirmButton.layer.cornerRadius = 8
        confirmButton.clipsToBounds = true
        confirmButton.isEnabled = true
        confirmButton.anchors.height.equal(40)
    }
    
    private func setupDefaultAllProcessRadioButton(isActive: Bool, activeColor: UIColor) {
        getNotifyRadioButton.set(isActive: isActive, activeColor: activeColor)
        sendIdentityRadioButton.set(isActive: isActive, activeColor: activeColor)
        waitingVerifyRadioButton.set(isActive: isActive, activeColor: activeColor)
    }
    
    private func setupRadioButtons(by status: VerifyIdentityStatusType) {
        setupDefaultAllProcessRadioButton(isActive: true, activeColor: .placeholder)
        switch status {
        case .unverified, .revision, .rejected:
            break
        case .uploaded:
            waitingVerifyRadioButton.isActive = false
            getNotifyRadioButton.isActive = false
        case .checking, .validating, .waiting_verification:
            getNotifyRadioButton.isActive = false
        case .verified:
            getNotifyRadioButton.set(isActive: true)
            sendIdentityRadioButton.set(isActive: true)
            waitingVerifyRadioButton.set(isActive: true)
        }
    }
    
    private func setupConfirmButton(with item: VerifyIdentityStatusItem) {
        switch item.verificationStatusType {
        case .revision, .rejected:
            confirmButton.setTitle("Ulangi proses verifikasi")
            confirmButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
            confirmButton.setBackgroundColor(.gradientStoryOne, for: .normal)
            confirmButton.setTitleColor(.placeholder, for: .disabled)
            confirmButton.setTitleColor(.white, for: .normal)
            
//            if !item.isEmailRevision || !item.isPhoneNumberRevision {
//                confirmButton.isEnabled = false
//            } else {
                confirmButton.isEnabled = true
//            }
            
        default:
            confirmButton.isEnabled = true
            confirmButton.setTitle("Saya mengerti")
        }
    }
    
    private func setupTitleAndSubtitle(by type: VerifyIdentityStatusType) {
        switch type {
        case .unverified, .revision, .rejected:
            titleLabel.text = "Identitas belum berhasil di verifikasi"
            subtitleLabel.text = "Periksa alasan verifikasi belum berhasil, dan silahkan mencoba kembali dengan memperbaiki data sesuai alasan dibawah ini."
        case .uploaded:
            titleLabel.text = "Identitas diupload"
            subtitleLabel.text = "Kamu akan menerima pemberitahuan di kotak masuk aplikasi tentang statusnya, atau kamu dapat memeriksanya di halaman Saldo."
        case .checking, .validating, .waiting_verification:
            titleLabel.text = "Informasi identitas sedang diverifikasi"
            subtitleLabel.text = "Anda akan menerima pemberitahuan di kotak masuk aplikasi tentang statusnya, atau Anda dapat memeriksanya di halaman Saldo."
        case .verified:
            titleLabel.text = "Identitas berhasil di verifikasi"
            subtitleLabel.text = "Identitas kamu sudah di verifikasi"
        }
    }
}

private extension KKRadioButtonView {
    func set(
        isEnable: Bool = false,
        isActive: Bool = false,
        color: UIColor = .placeholder,
        activeColor: UIColor = .alien
    ) {
        self.isEnable = isEnable
        self.color = color
        self.activeColor = activeColor
        self.isActive = isActive
    }
}
