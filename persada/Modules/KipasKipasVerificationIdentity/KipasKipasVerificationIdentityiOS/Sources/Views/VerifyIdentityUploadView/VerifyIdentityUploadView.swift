import UIKit
import KipasKipasShared

protocol VerifyIdentityUploadViewDelegate: AnyObject {
    func didClickCaptureIdentityButton()
    func didClickCaptureSelfieButton()
    func didClickGuideLine()
    func didClickNext()
}

class VerifyIdentityUploadView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nextButton: KKLoadingButton!
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var captureSelfieButton: UIButton!
    @IBOutlet weak var identityImageView: UIImageView!
    @IBOutlet weak var captureIdentityButton: UIButton!
    @IBOutlet weak var captureSelfieContainerStack: UIStackView!
    @IBOutlet weak var captureIdentityContainerStack: UIStackView!
    @IBOutlet weak var guidelineContainerStack: UIStackView!
    
    weak var delegate: VerifyIdentityUploadViewDelegate?
    
    var identityImage: UIImage? {
        didSet {
            identityImageView.image = identityImage
            setupCaptureButton()
        }
    }
    
    var selfieImage: UIImage? {
        didSet {
            selfieImageView.image = selfieImage
            setupCaptureButton()
        }
    }
    
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
        overrideUserInterfaceStyle = .light
        configureUI()
        configureNextButton()
    }
    
    @IBAction func didClickCaptureIdentityButton(_ sender: Any) {
        delegate?.didClickCaptureIdentityButton()
    }
    
    @IBAction func didClickCaptureSelfieButton(_ sender: Any) {
        delegate?.didClickCaptureSelfieButton()
    }
    
    @IBAction func didClickNextButton(_ sender: Any) {
        delegate?.didClickNext()
    }
}

extension VerifyIdentityUploadView {
    
    private func configureUI() {
        let onTapGuideLineIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapGuideline))
        guidelineContainerStack.isUserInteractionEnabled = true
        guidelineContainerStack.addGestureRecognizer(onTapGuideLineIconGesture)
    }
    private func setupCaptureButton() {
        captureIdentityContainerStack.backgroundColor = identityImage == nil ? .primary : .black.withAlphaComponent(0.3)
        captureSelfieContainerStack.backgroundColor = selfieImage == nil ? .primary : .black.withAlphaComponent(0.3)
        captureIdentityButton.setTitle(identityImage == nil ? "Ambil foto" : "Ulangi", for: .normal)
        captureSelfieButton.setTitle(selfieImage == nil ? "Ambil foto" : "Ulangi", for: .normal)
        
        nextButton.isEnabled = identityImage != nil && selfieImage != nil
    }
    
    private func configureNextButton() {
        nextButton.indicatorPosition = .center
        nextButton.indicator = MaterialLoadingIndicatorSimple(radius: 10)
        nextButton.setBackgroundColor(.gradientStoryOne, for: .normal)
        nextButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
        nextButton.isEnabled = false
        nextButton.indicator.color = .gradientStoryOne
        nextButton.titleLabel?.font = .roboto(.bold, size: 14)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.setTitleColor(.placeholder, for: .disabled)
        nextButton.anchors.height.equal(40)
    }
    
    @objc private func handleOnTapGuideline() {
        delegate?.didClickGuideLine()
    }
    
    func setLoading(_ isLoading: Bool) {
        nextButton.isEnabled = !isLoading
        nextButton.setTitle(isLoading ? "" : "Selanjutnya")
        isLoading ? nextButton.showLoaderWithoutLimit([]) : nextButton.hideLoader()
    }
}
