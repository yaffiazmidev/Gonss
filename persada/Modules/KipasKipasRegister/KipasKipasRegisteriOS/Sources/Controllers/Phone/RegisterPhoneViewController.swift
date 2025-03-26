import UIKit
import KipasKipasRegister
import KipasKipasShared
import KipasKipasSharedFoundation

public final class RegisterPhoneViewController: UIViewController {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = RegisterPhoneView()
    
    private var method: RegisterOTPPlatform = .whatsapp
    private var phone: String = ""
    
    var requestOTP: Closure<RegisterRequestOTPParam>?
    var onSuccessRequestOTP: Closure<(String, Int)>?
    var redirectToLoginWithOTP: Closure<String>?
    
    private lazy var intervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter
    }()
    
    // MARK: Lifecycle
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setFirstResponder()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.resignResponder()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    // MARK: Methods
    private func observe() {
        mainView.loginButtonCallback = { [weak self] in 
            self?.dismiss(animated: true)
        }
        
        mainView.sendOTPButtonCallback = { [weak self] phoneNumber in
            guard let self = self else { return }
            view.endEditing(true)
            phone = phoneNumber.addZeroPrefixOnPhoneNumber()
            getOTP()
        }
        
        mainView.switchOTPMethodCallback = showOTPMethodController
    }
    
    private func getOTP() {
        requestOTP?(.init(
            phoneNumber: phone,
            platform: method
        ))
    }
    
    private func showOTPMethodController() {
        let otpMethodController = ChangeOTPMethodViewController()
        otpMethodController.didChoseSMS = { [weak self] in
            self?.method = .sms
            self?.getOTP()
        }
        otpMethodController.didChoseWhatsapp = { [weak self] in
            self?.method = .whatsapp
            self?.getOTP()
        }
        otpMethodController.modalPresentationStyle = .fullScreen
        present(otpMethodController, animated: true)
    }
}

// MARK: Presentation
extension RegisterPhoneViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension RegisterPhoneViewController: ResourceView {
    public func display(view viewModel: RegisterRequestOTPViewModel) {
        onSuccessRequestOTP?((phone, viewModel.countdownInterval))
    }
}

extension RegisterPhoneViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else {
            return
        }
        
        if let retryInterval = tooManyRequestErrorOccured(error) {
            mainView.showRequestedTooManyOTPError(
                method: method.desc,
                intervalDesc: intervalFormatter.string(from: retryInterval) ?? ""
            )
            view.endEditing(true)
            return
        }
        
        switch RegisterRequestOTPError(rawValue: error.code) {
        case .hasRegistered:
            redirectToLoginWithOTP?(phone)
        default:
            let defaultMessage = "Terjadi kesalahan. Silahkan coba lagi nanti."
            mainView.setErrorText(error.message ?? defaultMessage)
        }
    }
    
    private func tooManyRequestErrorOccured(_ error: AnyError) -> TimeInterval? {
        guard let error: RegisterTooManyOTPRequestError = error.decodeError() else {
            return nil
        }
        let interval = error.data.expireInSecond ?? error.data.tryInSecond ?? 0
        return TimeInterval(interval)
    }
}

// MARK: UI
private extension RegisterPhoneViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureScrollContainer()
        configureMainView()
    }
    
    private func configureScrollContainer() {
        scrollContainer.paddingLeft = 32
        scrollContainer.paddingRight = 32
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.top.pin(to: view.safeAreaLayoutGuide)
        scrollContainer.anchors.edges.pin(to: view, axis: .horizontal)
        scrollContainer.anchors.bottom.pin()
    }
    
    func configureMainView() {
        mainView.backgroundColor = .clear
        
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
