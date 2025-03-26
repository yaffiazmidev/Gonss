import UIKit
import KipasKipasShared

protocol VerifyIdentitySelectIdViewDelegate: AnyObject {
    func didClickNext()
    func didClickInfo()
    func didClickCountryOrRegion()
}

class VerifyIdentitySelectIdView: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ktpContainerStack: UIStackView!
    @IBOutlet weak var ktpRadioButtonView: KKRadioButtonView!
    @IBOutlet weak var nextButton: KKBaseButton!
    @IBOutlet weak var infoIconImageView: UIImageView!
    @IBOutlet weak var countryOrRegionContainerStack: UIStackView!
    @IBOutlet weak var selectedCountryLabel: UILabel!
    
    weak var delegate: VerifyIdentitySelectIdViewDelegate?
    
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

extension VerifyIdentitySelectIdView {
    private func configureUI() {
        configureNextButton()
        configureKTPCard()
    }
    
    private func configureNextButton() {
        nextButton.setBackgroundColor(.primary, for: .normal)
        nextButton.setBackgroundColor(UIColor(hexString: "#F9F9F9"), for: .disabled)
        nextButton.setTitleColor(.placeholder, for: .disabled)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.isEnabled = false
    }
    
    private func configureKTPCard() {
        ktpContainerStack.layer.borderWidth = 1
        ktpContainerStack.layer.borderColor = UIColor(hexString: "#D0D1D3").cgColor
        
        ktpRadioButtonView.color = UIColor(hexString: "#D0D1D3")
        ktpRadioButtonView.activeColor = UIColor(hexString: "#FD2B54")
        ktpRadioButtonView.isActive = false
    }
    
    private func actionHandlers() {
        let onTapInfoIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapInfo))
        infoIconImageView.isUserInteractionEnabled = true
        infoIconImageView.addGestureRecognizer(onTapInfoIconGesture)
        
        let onTapCountryOrRegionGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapCountryOrRegion))
        countryOrRegionContainerStack.isUserInteractionEnabled = true
        countryOrRegionContainerStack.addGestureRecognizer(onTapCountryOrRegionGesture)
        
        let onTapKTPContainerStackGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapKTPContainerStack))
        ktpContainerStack.isUserInteractionEnabled = true
        ktpContainerStack.addGestureRecognizer(onTapKTPContainerStackGesture)
        
        ktpRadioButtonView.handleToggleSelection = { [weak self] isActive in
            guard let self = self else { return }
            self.ktpContainerStack.layer.borderColor = UIColor(hexString: isActive ? "#FD2B54" : "#D0D1D3").cgColor
            self.nextButton.isEnabled = isActive
        }
    }
    
    @objc private func handleOnTapInfo() {
        delegate?.didClickInfo()
    }
    
    @objc private func handleOnTapCountryOrRegion() {
        delegate?.didClickCountryOrRegion()
    }
    
    @objc private func handleOnTapKTPContainerStack() {
        let isActive = !nextButton.isEnabled
        ktpContainerStack.layer.borderColor = UIColor(hexString: isActive ? "#FD2B54" : "#D0D1D3").cgColor
        nextButton.isEnabled = isActive
        ktpRadioButtonView.isActive = isActive
    }
}
