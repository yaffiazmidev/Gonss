import UIKit
import KipasKipasShared

public final class LoginOptionsViewController: UIViewController {
    
    private let navBar = FakeNavBar()
    private let registerCTAStackView = UIView()
    private let scrollContainer = UIStackView()
    
    private lazy var buttonsCollectionView = ButtonsCollectionView(
        buttons: [makeMainLoginButton()]
    )
    
    private let tncLabel = InteractiveLabel()
    
    public var didTapLogin: EmptyClosure?
    public var didTapRegister: EmptyClosure?
    public var didTapTermsAndCondition: EmptyClosure?
    public var didTapPrivacyPolicy: EmptyClosure?
    
    public var onWillDismiss: EmptyClosure?
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onWillDismiss?()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    @objc private func didTapClose() {
        forceDismiss(animated: true)
    }
}

// MARK: UI
private extension LoginOptionsViewController {
    func configureUI() {
        view.backgroundColor = .white
        configureFakeNavbar()
        configureRegisterCTAView()
        configureScrollContainer()
        configureLoginButtons()
        configureTNCLabel()
        
        buttonsCollectionView.reloadData()
        view.layoutIfNeeded()
    }
    
    func configureFakeNavbar() {
        navBar.backgroundColor = .white
        navBar.height = 64
        navBar.separatorView.backgroundColor = .clear
        navBar.titleLabel.textColor = .night
        navBar.titleLabel.font = .roboto(.bold, size: 18)
        
        navBar.leftButton.setImage(UIImage.iconCircleQuestion)
        
        let iconClose = UIImage.iconCloseWhite?.withRenderingMode(.alwaysTemplate).withTintColor(.night)
        navBar.rightButton.setImage(iconClose)
        navBar.rightButton.contentEdgeInsets.right = 4
        navBar.rightButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        view.addSubview(navBar)
    }
    
    func configureScrollContainer() {
        scrollContainer.isUserInteractionEnabled = true
        scrollContainer.axis = .vertical
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.top.spacing(0, to: navBar.anchors.bottom)
        scrollContainer.anchors.edges.pin(to: view, insets: 32, axis: .horizontal)
        scrollContainer.anchors.bottom.spacing(0, to: registerCTAStackView.anchors.top)
    }
    
    func configureLoginButtons() {
        buttonsCollectionView.updateTitle = { [weak self] updateNavbar in
            self?.navBar.titleLabel.text = updateNavbar ? "Masuk ke KipasKipas" : nil
        }
        
        scrollContainer.addArrangedSubview(buttonsCollectionView)
        scrollContainer.addArrangedSubview(spacer(16))
    }
    
    func configureTNCLabel() {
        let country = InteractiveLabelType.custom(pattern: "Indonesia")
        let service = InteractiveLabelType.custom(pattern: "Ketentuan Layanan")
        let privacy = InteractiveLabelType.custom(pattern: "Kebijakan Privasi")
        
        let text = "Dengan menggunakan akun yang berlokasi di Indonesia, kamu menyetujui Ketentuan Layanan\n kami dan menyatakan bahwa kamu telah\n membaca Kebijakan Privasi kami."
        
        tncLabel.enabledTypes = [country, service, privacy]
        tncLabel.text = text
        tncLabel.customColor[country] = .night
        
        tncLabel.customColor[service] = .night
        tncLabel.handleCustomTap(for: service) { [weak self] _ in
            self?.didTapTermsAndCondition?()
        }
        
        tncLabel.customColor[privacy] = .night
        tncLabel.handleCustomTap(for: privacy) { [weak self] _ in
            self?.didTapPrivacyPolicy?()
        }
        
        tncLabel.font = .roboto(.regular, size: 13)
        tncLabel.highlightedFont = UIFont.roboto(.bold, size: 13)
        tncLabel.textColor = .boulder
        tncLabel.textAlignment = .center
        tncLabel.numberOfLines = 0
        tncLabel.textAlignment = .center
        tncLabel.numberOfLines = 0
        
        scrollContainer.addArrangedSubview(tncLabel)
        scrollContainer.addArrangedSubview(spacer(16))
    }
    
    func configureRegisterCTAView() {
        let wordingLabel = UILabel()
        wordingLabel.text = "Belum memiliki akun?"
        wordingLabel.textColor = .night
        wordingLabel.font = .roboto(.regular, size: 16)
        wordingLabel.textAlignment = .right
        
        let registerButton = UIButton()
        registerButton.setTitle("Mendaftar", for: .normal)
        registerButton.setTitleColor(.watermelon, for: .normal)
        registerButton.titleLabel?.font = .roboto(.bold, size: 16)
        registerButton.contentHorizontalAlignment = .leading
        registerButton.onTap(action: didTapRegister)
        
        let stack = UIStackView()
        stack.alignment = .center
        stack.spacing = 8
        stack.addArrangedSubview(wordingLabel)
        stack.addArrangedSubview(registerButton)
        
        registerCTAStackView.backgroundColor = .snowDrift
        registerCTAStackView.addSubview(stack)
        stack.anchors.center.align()
        
        wrapWithBottomSafeAreaPaddingView(registerCTAStackView, color: .snowDrift)
        registerCTAStackView.anchors.edges.pin(insets: 0, axis: .horizontal)
        registerCTAStackView.anchors.height.equal(80)
    }
}

// MARK: Buttons
private extension LoginOptionsViewController {
    func makeMainLoginButton() -> UIButton {
        let button = KKLoadingButton(icon: .iconUserOutline)
        button.titleInsets.left = 16
        button.titleInsets.right = 12
        button.iconInset = 10
        button.backgroundColor = .white
        button.adjustsFontSizeToFitWidth = true
        button.setCornerBorder(color: .ashGrey, cornerRadius: 8, borderWidth: 1)
        button.setTitle("Gunakan nomor telepon/email/nama pengguna")
        button.font = .roboto(.regular, size: 14)
        button.setTitleColor(.night, for: .normal)
        button.onTap(action: didTapLogin)
        return button
    }
}
