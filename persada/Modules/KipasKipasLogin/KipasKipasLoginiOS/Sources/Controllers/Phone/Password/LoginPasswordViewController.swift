import UIKit
import KipasKipasLogin
import KipasKipasShared
import KipasKipasSharedFoundation

public final class LoginPasswordViewController: UIViewController, NavigationAppearance {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = LoginPasswordView()
    
    var onSuccessLogin: Closure<LoginResponse>?
    var onFailedLogin: Closure<AnyError>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private let phoneNumber: Phone
    
    init(phoneNumber: Phone) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    var forgotPassword: EmptyClosure?
    var login: Closure<LoginRequestParam>?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(backIndicator: .iconChevronLeft)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.setFirstResponder()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.resignResponder()
    }
    
    // MARK: Helpers
    private func observe() {
        mainView.didTapLogin = weakify(self, LoginPasswordViewController.login(with:))
        mainView.didTapForgotPassword = forgotPassword
    }
    
    private func login(with password: String) {
        view.endEditing(true)
        
        login?(.init(
            username: phoneNumber,
            deviceId: deviceId,
            password: password
        ))
    }
}

// MARK: ResourceView, ResourceLoadingView, ResourceErrorView
extension LoginPasswordViewController: ResourceView {
    public func display(view viewModel: LoginViewModel) {
        onSuccessLogin?(viewModel.response)
    }
}

extension LoginPasswordViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

extension LoginPasswordViewController: ResourceErrorView {
    public func display(error viewModel: ResourceErrorViewModel) {
        guard let error = viewModel.error else { return }
        
        switch LoginError(rawValue: error.code) {
        case .authorizationFailed:
            mainView.setErrorText("Akun atau kata sandi salah")
        case .loginFreeze:
            mainView.setErrorText("Akun atau kata sandi salah. Akun anda dikunci untuk sementara.")
        case .none:
            mainView.setErrorText(error.message ?? "")
        }
        
        onFailedLogin?(error)
    }
}

// MARK: UI
private extension LoginPasswordViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.setRightBarButton(.init(image: .iconCircleQuestion, style: .done, target: nil, action: nil), animated: false)
        
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
