import UIKit
import KipasKipasShared

protocol VerifyIdentityApprovalViewDelegate: AnyObject {
    func didClickNext()
    func didClickGuideline()
}

class VerifyIdentityApprovalView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var approvalRadioButtonView: KKRadioButtonView!
    @IBOutlet weak var nextButton: KKBaseButton!
    @IBOutlet weak var guidelineContainerStack: UIStackView!
    
    weak var delegate: VerifyIdentityApprovalViewDelegate?
    
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
        actionHandlers()
    }
    
    @IBAction func didClickNextButton(_ sender: Any) {
        delegate?.didClickNext()
    }
}

extension VerifyIdentityApprovalView {
    private func configureUI() {
        configureNextButton()
        
        approvalRadioButtonView.color = UIColor(hexString: "#D0D1D3")
        approvalRadioButtonView.activeColor = UIColor(hexString: "#FD2B54")
        approvalRadioButtonView.isActive = false
    }
    
    private func configureNextButton() {
        nextButton.setBackgroundColor(.primary, for: .normal)
        nextButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
        nextButton.setTitleColor(.placeholder, for: .disabled)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.isEnabled = false
    }
    
    private func actionHandlers() {
        let onTapGuidelineIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapGuideline))
        guidelineContainerStack.isUserInteractionEnabled = true
        guidelineContainerStack.addGestureRecognizer(onTapGuidelineIconGesture)
        
        approvalRadioButtonView.handleToggleSelection = { [weak self] isActive in
            guard let self = self else { return }
            self.nextButton.isEnabled = isActive
        }
    }
    
    @objc private func handleOnTapGuideline() {
        delegate?.didClickGuideline()
    }
}
