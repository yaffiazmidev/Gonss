import UIKit
import KipasKipasShared

final class ChangeOTPMethodViewController: UIViewController {
    
    private let container = ScrollContainerView()
    private let infoLabel = UILabel()
    private let whatsappButton = KKLoadingButton(icon: .iconWhatsapp, text: "Kirim ke Whatsapp")
    private let smsButton = KKLoadingButton(icon: .iconSms, text: "Kirim lewat pesan")
    
    var didChoseWhatsapp: (() -> Void)?
    var didChoseSMS: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: UI
private extension ChangeOTPMethodViewController {
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(container)
        
        configureContainer()
    }
    
    func configureContainer() {
        container.isCentered = true
        container.spacingBetween = 16
        container.isScrollEnabled = false
        container.contentInsetAdjustmentBehavior = .never
        
        container.anchors.edges.pin(axis: .vertical)
        container.anchors.edges.pin(insets: 32, axis: .horizontal)
        
        configureInfoLabel()
        configureWhatsappButton()
        configureSMSButton()
    }
    
    func configureInfoLabel() {
        infoLabel.text = "Pilih metode untuk menerima kode OTP"
        infoLabel.font = .roboto(.medium, size: 12)
        infoLabel.textAlignment = .center
        infoLabel.textColor = .gravel
        
        container.addArrangedSubViews(infoLabel)
        container.addArrangedSubViews(spacer(16))
    }
    
    func configureWhatsappButton() {
        whatsappButton.font = .roboto(.medium, size: 12)
        whatsappButton.setTitleColor(.gravel, for: .normal)
        whatsappButton.backgroundColor = .snowDrift
        whatsappButton.iconInset = (view.bounds.width - 32) / 4
        whatsappButton.addTarget(self, action: #selector(didTapWhatsapp), for: .touchUpInside)

        container.addArrangedSubViews(whatsappButton)
        whatsappButton.anchors.height.equal(44)
    }
    
    func configureSMSButton() {
        smsButton.font = .roboto(.medium, size: 12)
        smsButton.setTitleColor(.gravel, for: .normal)
        smsButton.backgroundColor = .snowDrift
        smsButton.iconInset = (view.bounds.width - 32) / 4
        smsButton.addTarget(self, action: #selector(didTapSMS), for: .touchUpInside)
        
        container.addArrangedSubViews(smsButton)
        smsButton.anchors.height.equal(44)
    }
    
    @objc private func didTapWhatsapp() {
        dismiss(animated: true) { [weak self] in
            self?.didChoseWhatsapp?()
        }
    }
    
    @objc private func didTapSMS() {
        dismiss(animated: true) { [weak self] in
            self?.didChoseSMS?()
        }
    }
}
