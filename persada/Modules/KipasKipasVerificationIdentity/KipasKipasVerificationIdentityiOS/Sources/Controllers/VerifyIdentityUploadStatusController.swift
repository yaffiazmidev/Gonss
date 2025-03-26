import UIKit
import KipasKipasShared
import KipasKipasVerificationIdentity

public class VerifyIdentityUploadStatusController: UIViewController, NavigationAppearance {

    private lazy var mainView: VerifyIdentityUploadStatusView = {
        let view = VerifyIdentityUploadStatusView()
        view.delegate = self
        return view
    }()
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    private let viewModel: IVerifyIdentityUploadStatusViewModel
    private var statusItem: VerifyIdentityStatusItem?
    private var handleBackToBalanceView: (() -> Void)?
    private let isFromUploadView: Bool
    
    public init(
        isFromUploadView: Bool = false,
        viewModel: IVerifyIdentityUploadStatusViewModel,
        handleBackToBalanceView: (() -> Void)?
    ) {
        self.isFromUploadView = isFromUploadView
        self.viewModel = viewModel
        self.handleBackToBalanceView = handleBackToBalanceView
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        makeCustomBackButton()
        viewModel.fetchStatus()
        handleOnTapComponents()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(backIndicator: .iconChevronLeft)
    }
    
    public override func loadView() {
        view = mainView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeCustomBackButton() {
        let customBackButton = UIButton(type: .system)
        let backButtonImage = UIImage.iconChevronLeft
        customBackButton.setImage(backButtonImage, for: .normal)
        customBackButton.tintColor = .contentGrey // Customize the color as needed
        customBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customBackButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        let customBackButtonItem = UIBarButtonItem(customView: customBackButton)
        navigationItem.leftBarButtonItem = customBackButtonItem
    }
    
    @objc func backButtonTapped() {
        guard isFromUploadView else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        handleBackToBalanceView?()
    }
    
    private func navigateToSelectId() {
        let countryLoader: VerifyIdentityCountryLoader = VerifyIdentityLoaderFactory.shared.get(.country)
        let viewModel = VerifyIdentitySelectIdViewModel(countryLoader: countryLoader)
        let vc = VerifyIdentitySelectIdController(viewModel: viewModel, handleBackToBalanceView: handleBackToBalanceView)
        viewModel.delegate = vc
        push(vc)
    }
}

extension VerifyIdentityUploadStatusController: VerifyIdentityUploadStatusViewModelDelegate {
    public func displayVerifyIdentityStatus(item: VerifyIdentityStatusItem) {
        statusItem = item
        mainView.setupView(statusItem: item)
        updateUserStoredDataEmail()
        updateUserStoredDataPhoneNumber()
    }
    
    public func displayError(with message: String) {
        // TODO: setDefault View
    }
    
    public func displayErrorUploadVerifyIdentity(with message: String) {
        let description = "Terjadi kesalahan saat upload, silahkan coba lagi.."
        presentAlert(config: .init(title: "Gagal upload", description: description, iconImage: .iconCircleCloseFillRed))
    }
}

extension VerifyIdentityUploadStatusController: VerifyIdentityUploadStatusViewDelegate {
    func didClickConfirmButton() {
        
        guard statusItem?.submitCount ?? 0 < 5 else {
            presentLimitVerify()
            return
        }
        
        switch statusItem?.verificationStatusType ?? .unverified {
        case .revision, .rejected:
            navigateToSelectId()
        default:
            handleBackToBalanceView?()
        }
    }
    
    public func presentLimitVerify() {
        let view = VerifyIdentityInfoCheckView()
        let bottomSheetConfig = KKBottomSheetConfigureItem(viewHeight: 350, canSlideUp: false, canSlideDown: false)
        let vc = KKBottomSheetController(view: view, configure: bottomSheetConfig)
        view.setupViewType(with: .limit)
        view.handleDismiss = { [weak self] in
            guard let self = self else { return }
            vc.animateDismissView { [weak self] in
                guard let self = self else { return }
                
                switch statusItem?.verificationStatusType ?? .unverified {
                case .uploaded, .checking, .validating, .waiting_verification, .verified:
                    self.handleBackToBalanceView?()
                case .unverified, .rejected, .revision:
                    self.navigateToSelectId()
                }
            }
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
}

extension VerifyIdentityUploadStatusController {
    private func updateUserStoredDataEmail() {
        switch statusItem?.verificationStatusType {
        case .unverified, .revision, .rejected:
            let storedItem = verifyIdentityStored.retrieve()
            
            if storedItem?.isEmailUpdated == true {
                mainView.emailLabel.text = storedItem?.userEmail ?? ""
                mainView.emailStatusIconImageView.image = .iconCircleCheckGreen
                mainView.changeEmailLabel.isHidden = true
                statusItem?.isEmailRevision = false
            }
            
            mainView.confirmButton.isEnabled = statusItem?.isEmailRevision == false && statusItem?.isPhoneNumberRevision == false
        default:
            break
        }
    }
    
    private func updateUserStoredDataPhoneNumber() {
        switch statusItem?.verificationStatusType {
        case .unverified, .revision, .rejected:
            let storedItem = verifyIdentityStored.retrieve()
            
            if storedItem?.isPhoneNumberUpdated == true {
                mainView.phoneNumberLabel.text = storedItem?.userMobile ?? ""
                mainView.phoneNumberStatusIconImageView.image = .iconCircleCheckGreen
                mainView.changePhoneNumberLabel.isHidden = true
                statusItem?.isPhoneNumberRevision = false
            }
            
            mainView.confirmButton.isEnabled = statusItem?.isEmailRevision == false && statusItem?.isPhoneNumberRevision == false
        default:
            break
        }
    }
    
    private func handleOnTapComponents() {
        
        mainView.changeEmailLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.presentInputEmail()
        }
        
        mainView.changePhoneNumberLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.presentInputPhoneNumber()
        }
    }
    
    private func presentInputEmail() {
        let vc = VerifyIdentityInputEmailController()
        vc.handleDidSaveEmail = { [weak self] _ in
            guard let self = self else { return }
            self.updateUserStoredDataEmail()
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    private func presentInputPhoneNumber() {
        let vc = VerifyIdentityInputPhoneNumberController()
        vc.handleDidSavePhoneNumber = { [weak self] _ in
            guard let self = self else { return }
            self.updateUserStoredDataPhoneNumber()
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}
