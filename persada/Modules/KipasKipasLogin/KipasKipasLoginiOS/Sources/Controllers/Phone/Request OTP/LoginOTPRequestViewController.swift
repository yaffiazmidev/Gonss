import UIKit
import KipasKipasLogin
import KipasKipasShared
import KipasKipasSharedFoundation

public final class LoginOTPRequestViewController: UIViewController {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = LoginOTPRequestView()
    
    private var phoneNumber: Phone = ""
    
    var requestOTP: Closure<LoginOTPRequestParam>?
    var onSuccessRequestOTP: Closure<(Phone, TimeInterval)>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setFirstResponder()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.resignResponder()
    }
    
    private func observe() {
        mainView.sendOTPButtonCallback = { [weak self] phoneNumber in
            guard let self = self else { return }
            view.endEditing(true)
            self.phoneNumber = phoneNumber.addZeroPrefixOnPhoneNumber()
            getOTP()
        }
    }
    
    private func getOTP() {
        mainView.setLoading(true)
        requestOTP?(.init(
            phoneNumber: phoneNumber,
            platform: platform
        ))
    }
}

extension LoginOTPRequestViewController: ResourceView {
    public func display(view viewModel: LoginOTPRequestViewModel) {
        onSuccessRequestOTP?((phoneNumber, viewModel.countdownInterval))
    }
}

extension LoginOTPRequestViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

extension LoginOTPRequestViewController: ResourceErrorView {
    public func display(error viewModel: ResourceErrorViewModel) {
        if tooManyRequestErrorOccured(viewModel) {
            mainView.showRequestedTooManyOTPError()
            return
        }
        
        mainView.setErrorText("Terjadi kesalahan. Silahkan coba lagi nanti.")
    }
    
    private func tooManyRequestErrorOccured(_ viewModel: ResourceErrorViewModel) -> Bool {
        let error: LoginOTPTooManyRequestError? = viewModel.error?.decodeError()
        return error != nil
    }
}

private extension LoginOTPRequestViewController {
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
        
        scrollContainer.addArrangedSubViews(spacer(64))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
