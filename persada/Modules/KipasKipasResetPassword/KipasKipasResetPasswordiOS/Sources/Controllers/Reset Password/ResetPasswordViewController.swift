import UIKit
import KipasKipasResetPassword
import KipasKipasShared
import KipasKipasSharedFoundation

public final class ResetPasswordViewController: UIViewController, NavigationAppearance {
    
    private let mainView = ResetPasswordView()
    private let scrollContainer = ScrollContainerView()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Reset", backIndicator: .iconChevronLeft)
    }
    
    var onResetPassword: Closure<ResetPasswordVerifyOTPResponse>?
    var onSuccessResetPassword: Closure<ResetPasswordLoginParam>?
    
    var onSuccessLogin: Closure<ResetPasswordLoginResponse>?
    var onFailedLogin: EmptyClosure?
    
    private var newPassword: String = ""
    
    private let response: ResetPasswordVerifyOTPResponse
    private let parameter: ResetPasswordParameter
    
    let loginViewAdapter = ViewAdapter<ResetPasswordLoginResponse>()
    
    init(
        parameter: ResetPasswordParameter,
        response: ResetPasswordVerifyOTPResponse
    ) {
        self.parameter = parameter
        self.response = response
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    private func observe() {
        loginViewAdapter.delegate = onSuccessLogin
        loginViewAdapter.delegateError = { [weak self] _ in self?.onFailedLogin?() }
        
        mainView.onTapNext = weakify(self, ResetPasswordViewController.resetPassword)
    }
    
    private func resetPassword(_ newPassword: String) {
        self.newPassword = newPassword
        
        view.endEditing(true)
        onResetPassword?(generateResetRequestParam(newPassword: newPassword))
    }
    
    private func generateResetRequestParam(newPassword: String) -> ResetPasswordVerifyOTPResponse {
        switch parameter.type {
        case let .phone(number):
            return .init(phone: .init(
                id: response.id,
                key: number,
                otpCode: response.otpCode,
                newPassword: newPassword,
                media: response.media
            ))
        case let .email(address):
            return .init(email: .init(
                id: response.id,
                newPassword: newPassword,
                token: response.token,
                deviceId: deviceId,
                code: response.code,
                email: address
            ))
        }
    }
    
    private func generateLoginParam(newPassword: String) -> ResetPasswordLoginParam {
        switch parameter.type {
        case let .phone(number):
            return .init(
                username: number,
                deviceId: deviceId,
                password: newPassword
            )
        case let .email(address):
            return .init(
                username: address,
                deviceId: deviceId,
                password: newPassword
            )
        }
    }
}

// MARK: ResourceView & ResourceLoadingView & ResourceErrorView
extension ResetPasswordViewController: ResourceView {
    public func display(view viewModel: ResetPasswordViewModel) {
        if viewModel.isSuccess {
            let param = generateLoginParam(newPassword: newPassword)
            onSuccessResetPassword?(param)
        }
    }
}

extension ResetPasswordViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

extension ResetPasswordViewController: ResourceErrorView {
    public func display(error viewModel: ResourceErrorViewModel) {
        guard let error = viewModel.error else { return }
        mainView.setErrorText(error.message ?? "")
    }
}

// MARK: UI
private extension ResetPasswordViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = .init(image: .iconCircleQuestion, style: .plain, target: nil, action: nil)
        
        configureScrollContainer()
        configurePasswordView()
    }
    
    private func configureScrollContainer() {
        scrollContainer.paddingLeft = 32
        scrollContainer.paddingRight = 32
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.top.pin(to: view.safeAreaLayoutGuide, inset: 0)
        scrollContainer.anchors.edges.pin(to: view, axis: .horizontal)
        scrollContainer.anchors.bottom.pin()
    }
    
    func configurePasswordView() {
        mainView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
