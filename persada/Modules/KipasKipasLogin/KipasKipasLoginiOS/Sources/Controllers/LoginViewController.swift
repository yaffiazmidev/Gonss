import UIKit
import KipasKipasLogin
import KipasKipasShared

public protocol LoginViewControllerDelegate: AnyObject {
    func showForgotPasswordPage()
}

public final class LoginViewController: UIViewController, NavigationAppearance {
    
    private let scrollContainer = ScrollContainerView()
    private let mainView = LoginView()
    
    public var loginCallback: Closure<LoginRequestParam>?
    public var onSuccessLogin: Closure<LoginResponse>?
    public var onFailedLogin: Closure<AnyError>?
        
    /// Username or email
    private let account: String?
    private weak var delegate: LoginViewControllerDelegate?
 
    public init(
        account: String?,
        delegate: LoginViewControllerDelegate
    ) {
        self.account = account
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Masuk", backIndicator: .iconChevronLeft)
    }
    
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
    
    private func observe() {
        mainView.loginButtonCallback = { [weak self] username, password in
            guard let self = self else { return }
            self.view.endEditing(true)
            self.loginCallback?(.init(
                username: username,
                deviceId: deviceId, 
                password: password, 
                otpCode: nil
            ))
        }
        
        mainView.forgotPasswordButtonCallback = delegate?.showForgotPasswordPage
    }
}

extension LoginViewController: ResourceView {
    public func display(view viewModel: LoginViewModel) {
        onSuccessLogin?(viewModel.response)
    }
}

extension LoginViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

extension LoginViewController: ResourceErrorView {
    public func display(error viewModel: ResourceErrorViewModel) {
        guard let error = viewModel.error else { return }
        
        switch LoginError(rawValue: error.code) {
        case .authorizationFailed:
            mainView.setErrorMessage("Akun atau kata sandi salah")
        case .loginFreeze:
            mainView.setErrorMessage("Akun atau kata sandi salah. Akun anda dikunci untuk sementara.")
        case .none:
            mainView.setErrorMessage(error.message ?? "")
        }
        
        onFailedLogin?(error)
    }
}

// MARK: UI
private extension LoginViewController {
    func configureUI() {
        view.backgroundColor = .white
        configureScrollContainer()
        configureMainView()
    }
    
    func configureScrollContainer() {
        scrollContainer.paddingLeft = 8
        scrollContainer.paddingRight = 8
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.edges.pin(to: view.safeAreaLayoutGuide, axis: .vertical)
        scrollContainer.anchors.edges.pin(to: view, axis: .horizontal)
    }
 
    func configureMainView() {
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 16
                
        if let account = account {
            mainView.setAccount(account)
            mainView.setHeadingVisibility(visible: account.isEmpty == false)
        } else {
            mainView.setHeadingVisibility(visible: false)
        }
        
        scrollContainer.addArrangedSubViews(mainView)
    }
}
