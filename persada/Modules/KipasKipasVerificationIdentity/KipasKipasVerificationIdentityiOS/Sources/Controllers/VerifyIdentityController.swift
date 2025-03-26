import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasVerificationIdentity

public class VerifyIdentityController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: VerifyIdentityView = {
        let view = VerifyIdentityView()
        view.delegate = self
        return view
    }()
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()
    
    public var router: IVerifyIdentityRouter?
    public let viewModel: IVerifyIdentityViewModel
    private let verificationStatus: VerifyIdentityStatusType
    
    public init(viewModel: IVerifyIdentityViewModel, verificationStatus: VerifyIdentityStatusType) {
        self.viewModel = viewModel
        self.verificationStatus = verificationStatus
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        mainView.setupStatus(by: verificationStatus)
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
}

extension VerifyIdentityController: VerifyIdentityViewModelDelegate {
    public func displayCheckVerifyIdentity(item: VerifyIdentityCheckItem) {
        var statusItem = item
        mainView.setLoading(false)
        let emailValue = item.emailValue
        let phoneNumberValue = item.phoneNumberValue
        
        if emailValue.isEmpty {
            router?.presentInfoCheck(
                by: .required(
                    email: "",
                    mobile: phoneNumberValue.isValidPhoneNumber() ? phoneNumberValue : "",
                    diamond: item.diamond
                )
            )
            return
        }
        
        if item.phoneNumberValue.isEmpty {
            router?.presentInfoCheck(
                by: .required(
                    email: emailValue.isValidEmail() ? emailValue : "",
                    mobile: "",
                    diamond: item.diamond
                )
            )
            return
        }
        
        if !item.email && verifyIdentityStored.retrieve()?.isEmailUpdated == false {
            router?.presentInfoCheck(
                by: .required(
                    email: emailValue.isValidEmail() ? emailValue : "",
                    mobile: phoneNumberValue.isValidPhoneNumber() ? phoneNumberValue : "",
                    diamond: item.diamond
                )
            )
            return
        }
        
        if !item.phone && verifyIdentityStored.retrieve()?.isPhoneNumberUpdated == false {
            router?.presentInfoCheck(
                by: .required(
                    email: emailValue.isValidEmail() ? emailValue : "",
                    mobile: phoneNumberValue.isValidPhoneNumber() ? phoneNumberValue : "",
                    diamond: item.diamond
                )
            )
            return
        }
        
//        guard item.diamond else {
//            router?.presentInfoCheck(
//                by: .required(
//                    email: emailValue.isValidEmail() ? emailValue : "",
//                    mobile: phoneNumberValue.isValidPhoneNumber() ? phoneNumberValue : "",
//                    diamond: false
//                )
//            )
//            return
//        }
        var storeData = verifyIdentityStored.retrieve()
        storeData?.userEmail = emailValue
        storeData?.userMobile = phoneNumberValue
        verifyIdentityStored.insert(storeData ?? .init(), completion: {_ in})
        router?.navigateToSelectId()
    }
    
    public func displayVerifyIdentityLimit() {
        mainView.setLoading(false)
        router?.presentInfoCheck(by: .limit)
    }
    
    public func displayError(with message: String) {
        mainView.setLoading(false)
    }
}

extension VerifyIdentityController: VerifyIdentityViewDelegate {
    func didClickVerifyNow() {
        switch verificationStatus {
        case .unverified:
            mainView.setLoading(true)
            viewModel.check()
        default:
            router?.navigateToUploadStatus()
        }
    }
    
    func didClickReward(item: VerifyIdentityView.VerifyIdentityReward) {
        switch item {
        case .channelFeeAwards:
            router?.presentChannelFeeAwards()
        case .verificationMark:
            router?.presentMarkInfo()
        default: break
        }
    }
}

extension VerifyIdentityController {
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        let faqButtonItem = UIBarButtonItem(image: .iconCircleQuestion, style: .plain, target: self, action: #selector(faqButtonPressed))
        navigationItem.rightBarButtonItem = faqButtonItem
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func faqButtonPressed() {
        router?.presentFAQ()
    }
}

extension VerifyIdentityController: UIGestureRecognizerDelegate {}
