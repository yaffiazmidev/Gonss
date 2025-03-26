import UIKit
import KipasKipasShared
import KipasKipasVerificationIdentity

protocol VerifyIdentityViewDelegate: AnyObject {
    func didClickVerifyNow()
    func didClickReward(item: VerifyIdentityView.VerifyIdentityReward)
}

class VerifyIdentityView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendingIDRadioButtonView: KKRadioButtonView!
    @IBOutlet weak var infoCheckingRadioButtonView: KKRadioButtonView!
    @IBOutlet weak var hasBeenVerifiedRadioButtonView: KKRadioButtonView!
    @IBOutlet weak var channelFeeAwardsActionLabel: UILabel!
    @IBOutlet weak var exclusivePrizesActionLabel: UILabel!
    @IBOutlet weak var hassleFreeExperienceActionLabel: UILabel!
    @IBOutlet weak var verificationMarkActionLabel: UILabel!
    @IBOutlet weak var verifyButton: KKLoadingButton!
    @IBOutlet weak var encryptContainerStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoCheckingDescLabel: UILabel!
    
    enum VerifyIdentityReward {
        case channelFeeAwards
        case exclusivePrizes
        case hassleFreeExperience
        case verificationMark
    }
    
    weak var delegate: VerifyIdentityViewDelegate?
    
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

    @IBAction func didClickVerifyNowButton(_ sender: Any) {
        delegate?.didClickVerifyNow()
    }
}

extension VerifyIdentityView {
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 87, right: 0)
        
        setupRadioButton()
        configureLoginButton()
        handleRewardAction()
    }
    
    private func setupRadioButton() {
        [sendingIDRadioButtonView,
         infoCheckingRadioButtonView,
         hasBeenVerifiedRadioButtonView].forEach { view in
            view?.isEnable = false
            view?.color = .placeholder
            view?.activeColor = UIColor(hexString: "#52C41A")
            view?.isActive = false
        }
    }
    
    func setupStatus(by type: VerifyIdentityStatusType) {
        setupRadioButton()
        
        verifyButton.setBackgroundColor(.gradientStoryOne, for: .normal)
        verifyButton.setBackgroundColor(.gradientStoryOne, for: .disabled)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.setTitleColor(.white, for: .disabled)
        
        infoCheckingDescLabel.isHidden = true
        
        switch type {
        case .unverified:
            verifyButton.setTitle("Verifikasi sekarang")
        case .revision, .rejected:
            sendingIDRadioButtonView.isActive = true
            infoCheckingRadioButtonView.isActive = true
            verifyButton.setTitle("Cek status verifikasi")
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .normal)
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
            verifyButton.setTitleColor(.contentGrey, for: .normal)
            verifyButton.setTitleColor(.contentGrey, for: .disabled)
        case .uploaded:
            sendingIDRadioButtonView.isActive = true
            verifyButton.setTitle("Cek status verifikasi")
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .normal)
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
            verifyButton.setTitleColor(.contentGrey, for: .normal)
            verifyButton.setTitleColor(.contentGrey, for: .disabled)
        case .checking, .validating, .waiting_verification:
            infoCheckingDescLabel.isHidden = false
            sendingIDRadioButtonView.isActive = true
            infoCheckingRadioButtonView.isActive = true
            verifyButton.setTitle("Cek status verifikasi")
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .normal)
            verifyButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
            verifyButton.setTitleColor(.contentGrey, for: .normal)
            verifyButton.setTitleColor(.contentGrey, for: .disabled)
        case .verified:
            encryptContainerStack.isHidden = true
            sendingIDRadioButtonView.isActive = true
            infoCheckingRadioButtonView.isActive = true
            hasBeenVerifiedRadioButtonView.isActive = true
            verifyButton.setTitle("Lihat informasi identitas")
            titleLabel.text = "Identitasmu sudah\n terverifikasi"
        }
    }
    
    func configureLoginButton() {
        verifyButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        verifyButton.indicatorPosition = .right
        verifyButton.setBackgroundColor(.gradientStoryOne, for: .normal)
        verifyButton.setBackgroundColor(.gradientStoryOne, for: .disabled)
        verifyButton.indicator.color = .white
        verifyButton.isEnabled = true
        verifyButton.titleLabel?.font = .roboto(.bold, size: 16)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.setTitleColor(.white, for: .disabled)
        verifyButton.layer.cornerRadius = 8
        verifyButton.clipsToBounds = true
        verifyButton.anchors.height.equal(40)
    }
    
    private func handleRewardAction() {
        channelFeeAwardsActionLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickReward(item: .channelFeeAwards)
        }
        
        exclusivePrizesActionLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickReward(item: .exclusivePrizes)
        }
        
        hassleFreeExperienceActionLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickReward(item: .hassleFreeExperience)
        }
        
        verificationMarkActionLabel.addTapGesture { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickReward(item: .verificationMark)
        }
    }
}

extension VerifyIdentityView {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            verifyButton.showLoader([])
        } else {
            verifyButton.hideLoader()
        }
    }
}
