import UIKit
import Combine
import KipasKipasLogin
import KipasKipasShared
import KipasKipasSharedFoundation

public final class LoginWithOTPViewController: UIViewController, NavigationAppearance {
    
    private lazy var mainView = LoginWithOTPView()
    
    private let scrollContainer = ScrollContainerView()
    private let loginWithPasswordButton = KKBaseButton()
    
    private var loginWithPasswordButtonBottomConstraint: NSLayoutConstraint! {
        didSet {
            loginWithPasswordButtonBottomConstraint.isActive = true
        }
    }
    
    private var keyboardHandler: KeyboardHandler?
    private var otpCode: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    private var countdownCancellable: AnyCancellable?
    
    var onLoginWithOTP: Closure<LoginRequestParam>?
    var onTapRegister: Closure<(Phone, String)>?
    var onResendOTP: Closure<LoginOTPRequestParam>?
    var onSuccessLogin: Closure<LoginResponse>?
    
    var didTapLoginWithPassword: Closure<Phone>?
    
    private let phoneNumber: Phone
    private var interval: TimeInterval
    
    let requestOTPAdapter: ViewAdapter<LoginOTPRequestViewModel>

    init(
        phoneNumber: Phone,
        interval: TimeInterval,
        requestOTPAdapter: ViewAdapter<LoginOTPRequestViewModel>
    ) {
        self.phoneNumber = phoneNumber
        self.interval = interval
        self.requestOTPAdapter = requestOTPAdapter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(backIndicator: .iconChevronLeft)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountdown()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
        
        if interval == 0 {
            getOTP()
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        stopCountdown()
    }
    
    deinit {
        keyboardHandler?.unsubscribe()
    }
 
    // MARK: Helpers
    private func observe() {
        requestOTPAdapter.delegate = weakify(self, LoginWithOTPViewController.didRequestOTP)
        mainView.didTapResendOTP = weakify(self, LoginWithOTPViewController.getOTP)
        mainView.didFinishInputOTP = weakify(self, LoginWithOTPViewController.login)
        
        loginWithPasswordButton
            .tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                didTapLoginWithPassword?(phoneNumber)
            }
            .store(in: &cancellables)
        
        configureKeyboardObserver()
    }
    
    private func getOTP() {
        onResendOTP?(.init(
            phoneNumber: phoneNumber,
            platform: platform
        ))
    }
    
    private func login(code: String) {
        otpCode = code
        
        onLoginWithOTP?(.init(
            username: phoneNumber,
            deviceId: deviceId,
            password: nil,
            otpCode: code,
            platform: platform
        ))
    }
    
    private func startCountdown() {
        countdownCancellable = CountDownTimer(
            duration: interval,
            repeats: false,
            outputUnits: [.minute, .second]
        )
        .handleEvents(receiveOutput: { [weak self] remaining in
            if remaining.totalSeconds < 0 {
                self?.stopCountdown()
            }
        })
        .sink(receiveValue: { [interval, weak self] remaining in
            self?.mainView.setTimerText(
                remaining.outputText,
                isTimerEnded: remaining.totalSeconds <= 0,
                shouldShowCallMethod: remaining.totalSeconds <= Int(interval) / 2
            )
        })
    }
    
    private func stopCountdown() {
        interval = 0
        mainView.setTimerText("", isTimerEnded: true, shouldShowCallMethod: true)
        countdownCancellable?.cancel()
        countdownCancellable = nil
    }
    
    private func resetCountdown(_ countdown: TimeInterval) {
        interval = countdown
        startCountdown()
    }
    
    private func showRegisterAlert() {
        let alert = UIAlertController(
            title: "Nomor telepon ini belum terdaftar. Buat akun dengan nomor ini?",
            message: nil,
            preferredStyle: .alert
        )
        alert.setTitleFont(.roboto(.medium, size: 17))
        
        let createAccount = UIAlertAction(
            title: "Buat akun",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            onTapRegister?((phoneNumber, otpCode))
        }
        
        let back = UIAlertAction(
            title: "Kembali",
            style: .cancel
        ) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.overrideUserInterfaceStyle = .light
        alert.addAction(createAccount)
        alert.addAction(back)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: API
extension LoginWithOTPViewController {
    private func didRequestOTP(_ viewModel: LoginOTPRequestViewModel) {
        resetCountdown(viewModel.countdownInterval)
    }
}

// MARK: ResourceView, ResourceErrorView, ResourceLoadingView
extension LoginWithOTPViewController: ResourceView {
    public func display(view viewModel: LoginViewModel) {
        onSuccessLogin?(viewModel.response)
    }
}

extension LoginWithOTPViewController: ResourceErrorView {
    public func display(error viewModel: ResourceErrorViewModel) {
        guard let error = viewModel.error else { return }
        
        if let _ = tooManyRequestErrorOccured(viewModel) {
            mainView.showRequestedTooManyOTPError()
            view.endEditing(true)
            return
        }

        switch LoginWithOTPError(rawValue: error.code) {
        case .wrongOTP:
            mainView.setErrorMessage("Kode salah")
        case .userFreeze:
            // This is a code smell. But the BE contract made me.
            if let json: String = error.message,
               let data = json.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(LoginOTPRequestResponse.self, from: data) {
                
                mainView.setErrorMessage("Verifikasi gagal. Ketuk Kirim Ulang dan coba lagi.")
                let interval = decoded.tryInSecond ?? 0
                resetCountdown(TimeInterval(interval))
            }
           
        case .credentialNotFound:
            mainView.setErrorMessage(nil)
            showRegisterAlert()
            stopCountdown()
        case .none:
            mainView.setErrorMessage(error.message ?? "")
        }
    }
    
    private func tooManyRequestErrorOccured(_ viewModel: ResourceErrorViewModel) -> LoginOTPTooManyRequestError? {
        return viewModel.error?.decodeError()
    }
}

extension LoginWithOTPViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

// MARK: Keyboard Handling
private extension LoginWithOTPViewController {
    func configureKeyboardObserver() {
        keyboardHandler = KeyboardHandler(with: weakify(
            self, LoginWithOTPViewController.handleKeyboard
        ))
    }
    
    func handleKeyboard(_ state: KeyboardState) {
        switch state.state {
        case .willShow:
            UIView.animate(withDuration: 0.3) {
                self.moveViewAboveKeyboard(height: state.height)
                self.view.layoutIfNeeded()
            }
        case .willHide:
            UIView.animate(withDuration: 0.3) {
                self.resetViewPosition()
            }
        default: break
        }
    }
   
    func moveViewAboveKeyboard(height: CGFloat) {
        let viewHeight = loginWithPasswordButton.frame.size.height
        let keyboardY = height - (viewHeight / 2)
        
        if loginWithPasswordButtonBottomConstraint.constant == 0 {
            loginWithPasswordButtonBottomConstraint.constant = -keyboardY
        }
    }
    
    func resetViewPosition() {
        if loginWithPasswordButtonBottomConstraint.constant < 0 {
            loginWithPasswordButtonBottomConstraint.constant = 0
        }
    }
}

// MARK: UI
private extension LoginWithOTPViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.setRightBarButton(.init(image: .iconCircleQuestion, style: .done, target: nil, action: nil), animated: false)

        configureSpacer()
        configureScrollContainer()
        configureMainView()
        configureLoginWithPasswordButton()
    }
    
    func configureSpacer() {
        scrollContainer.addArrangedSubViews(spacer(32))
    }
    
    private func configureScrollContainer() {
        scrollContainer.paddingLeft = 32
        scrollContainer.paddingRight = 32
        
        view.addSubview(scrollContainer)
        scrollContainer.anchors.top.pin(to: view.safeAreaLayoutGuide, inset: 0)
        scrollContainer.anchors.edges.pin(to: view, axis: .horizontal)
        scrollContainer.anchors.bottom.pin()
    }
    
    func configureMainView() {
        mainView.backgroundColor = .clear
        mainView.setSubheadingText(phoneNumber)
        scrollContainer.addArrangedSubViews(mainView)
    }
    
    func configureLoginWithPasswordButton() {
        loginWithPasswordButton.setTitle("Masuk dengan kata sandi")
        loginWithPasswordButton.setTitleColor(.night, for: .normal)
        loginWithPasswordButton.font = .roboto(.medium, size: 14)
        loginWithPasswordButton.contentHorizontalAlignment = .left
        loginWithPasswordButton.backgroundColor = .clear
        
        loginWithPasswordButtonBottomConstraint = wrapWithBottomSafeAreaPaddingView(loginWithPasswordButton, color: .clear)
        loginWithPasswordButton.anchors.edges.pin(insets: 32, axis: .horizontal)
        loginWithPasswordButton.anchors.height.equal(74)
    }
}
