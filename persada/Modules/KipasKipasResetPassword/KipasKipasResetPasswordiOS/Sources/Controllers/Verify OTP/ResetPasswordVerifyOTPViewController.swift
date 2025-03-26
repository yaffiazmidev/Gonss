import UIKit
import Combine
import KipasKipasResetPassword
import KipasKipasShared
import KipasKipasSharedFoundation

public final class ResetPasswordVerifyOTPViewController: UIViewController, NavigationAppearance {
    
    private let mainView = ResetPasswordVerifyOTPView()
    private let scrollContainer = ScrollContainerView()
    
    private var countdownCancellable: AnyCancellable?
    
    var onResendOTP: Closure<ResetPasswordRequestOTPParam>?
    var onVerifyOTP: Closure<ResetPasswordVerifyOTPParam>?
    var onSuccessVerifyOTP: Closure<(ResetPasswordVerifyOTPResponse, ResetPasswordParameter)>?
    
    private let parameter: ResetPasswordParameter
    private var interval: TimeInterval
    
    let requestOTPAdapter: ViewAdapter<ResetPasswordOTPRequestViewModel>
    
    init(
        parameter: ResetPasswordParameter,
        requestOTPAdapter: ViewAdapter<ResetPasswordOTPRequestViewModel>
    ) {
        self.parameter = parameter
        self.requestOTPAdapter = requestOTPAdapter
        self.interval = parameter.countdown
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Reset", backIndicator: .iconChevronLeft)
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
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        stopCountdown()
    }
    
    private func observe() {
        requestOTPAdapter.delegate = weakify(self, ResetPasswordVerifyOTPViewController.didRequestOTP)
        mainView.didTapResendOTP = weakify(self, ResetPasswordVerifyOTPViewController.getOTP)
        mainView.didFinishInputOTP = weakify(self, ResetPasswordVerifyOTPViewController.verifyOTP)
    }
    
    // MARK: Helpers
    private func getOTP() {
        onResendOTP?(generateRequestOTPParam())
    }
    
    private func verifyOTP(code: String) {
        onVerifyOTP?(generateVerifyOTPParam(code: code))
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
        .sink(receiveValue: { [weak self] remaining in
            self?.mainView.setTimerText(
                remaining.outputText,
                isTimerEnded: remaining.totalSeconds <= 0
            )
        })
    }
    
    private func stopCountdown() {
        interval = 0
        mainView.setTimerText("", isTimerEnded: true)
        countdownCancellable?.cancel()
        countdownCancellable = nil
    }
    
    private func resetCountdown(_ countdown: TimeInterval) {
        interval = countdown
        startCountdown()
    }
}

// MARK: API
extension ResetPasswordVerifyOTPViewController {
    func didRequestOTP(_ viewModel: ResetPasswordOTPRequestViewModel) {
        resetCountdown(viewModel.countdownInterval)
    }
    
    public func setOTP(
        with code: String,
        token: String
    ) {
        mainView.setOTP(code)
        onVerifyOTP?(generateVerifyOTPParam(
            code: code,
            token: token
        ))
    }
}

// MARK: ResourceView, ResourceErrorView, ResourceLoadingView
extension ResetPasswordVerifyOTPViewController: ResourceView {
    public func display(view viewModel: ResetPasswordVerifyOTPResponse) {
        onSuccessVerifyOTP?((viewModel, parameter))
    }
}

extension ResetPasswordVerifyOTPViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        
        guard let error = errorViewModel.error else { return }
        
        switch ResetPasswordVerifyError(rawValue: error.code) {
        case .tooManyWrongInput:
            if let retryInterval = tooManyRequestErrorOccured(errorViewModel) {
                mainView.setErrorMessage(error.message)
                resetCountdown(retryInterval)
                view.endEditing(true)
                return
            }
            
        case .none:
            // Too many request OTP
            if let retryInterval = tooManyRequestErrorOccured(errorViewModel) {
                mainView.showRequestedTooManyOTPError()
                resetCountdown(retryInterval)
                view.endEditing(true)
                return
            }
            
            mainView.setErrorMessage(error.message)
        }
    }
    
    private func tooManyRequestErrorOccured(_ viewModel: ResourceErrorViewModel) -> TimeInterval? {
        guard let error: ResetPasswordTooManyOTPRequestError = viewModel.error?.decodeError() else {
            return nil
        }
        let interval = error.data.expireInSecond ?? error.data.tryInSecond ?? 0
        return TimeInterval(interval)
    }
}

extension ResetPasswordVerifyOTPViewController: ResourceLoadingView {
    public func display(loading viewModel: ResourceLoadingViewModel) {
        mainView.setLoading(viewModel.isLoading)
    }
}

// MARK: UI
private extension ResetPasswordVerifyOTPViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = .init(image: .iconCircleQuestion, style: .plain, target: nil, action: nil)
        
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
        
        switch parameter.type {
        case let .phone(phone):
            mainView.setHeadingText("Masukkan kode 4 digit")
            mainView.setSubheadingText("Kode akan dikirimkan ke +62 \(phone)")
        case let .email(address):
            mainView.setHeadingText("Verifikasi alamat email kamu")
            mainView.setSubheadingText("Untuk melanjutkan, selesaikan verifikasi email untuk mengkonfirmasi bahwa akun ini milik kamu. Kode telah dikirim ke \(address)")
        }
        
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}

// MARK: Parameter Generation
private extension ResetPasswordVerifyOTPViewController {
    func generateRequestOTPParam() -> ResetPasswordRequestOTPParam {
        switch parameter.type {
        case let .phone(phone):
            return .init(phone: .init(
                key: phone
            ))
        case let .email(address):
            return .init(email: .init(
                email: address,
                deviceId: deviceId
            ))
        }
    }
    
    func generateVerifyOTPParam(
        code: String,
        token: String? = nil
    ) -> ResetPasswordVerifyOTPParam {
        switch parameter.type {
        case let .phone(phone):
            return .init(phone: .init(
                code: code,
                phoneNumber: phone
            ))
        case let .email(address):
            guard let token = token else {
                return .init(email: .init(
                    code: code,
                    email: address
                ))
            }
            return .init(emailLink: .init(
                code: code,
                token: token,
                deviceId: deviceId
            ))
        }
    }
}
