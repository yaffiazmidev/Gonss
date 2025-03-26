import UIKit
import Combine
import KipasKipasRegister
import KipasKipasShared

public final class RegisterVerifyOTPViewController: StepsController {
    
    private let mainView = RegisterVerifyOTPView()
    
    private var countdownCancellable: AnyCancellable?
    
    var resendOTP: Closure<RegisterRequestOTPParam>?
    var verifyOTP: Closure<RegisterVerifyOTPParam>?
    
    private let requestOTPController: RequestOTPViewAdapter
    
    init(requestOTPController: RequestOTPViewAdapter) {
        self.requestOTPController = requestOTPController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountdown()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
        configureController()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        stopCountdown()
    }
    
    private func configureController() {
        requestOTPController.delegate = self
    }
    
    private func observe() {
        mainView.didTapResendOTP = { [weak self] in
            self?.getOTP()
        }
        
        mainView.didFinishInputOTP = { [weak self] code in
            guard let self = self else { return }
            storedData.otpCode = code
            
            verifyOTP?(.init(
                code: code,
                phoneNumber: storedData.phoneNumber,
                platform: storedData.otpType
            ))
        }
        
        mainView.didTapSwitchOTP = { [weak self] in
            self?.showOTPMethodController()
        }
    }
    
    private func getOTP() {
        resendOTP?(.init(
            phoneNumber: storedData.phoneNumber,
            platform: storedData.otpType
        ))
    }
    
    private func startCountdown() {
        countdownCancellable = CountDownTimer(
            duration: TimeInterval(storedData.otpExpirationDuration),
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
        storedData.otpExpirationDuration = 0
        mainView.setTimerText("", isTimerEnded: true)
        countdownCancellable?.cancel()
        countdownCancellable = nil
        resetUI()
    }
    
    private func resetUI() {
        mainView.resetUI()
    }
    
    private func resetCountdown(_ countdown: Int) {
        storedData.otpExpirationDuration = countdown
        startCountdown()
    }
    
    private func showOTPMethodController() {
        let otpMethodController = ChangeOTPMethodViewController()
        otpMethodController.didChoseSMS = { [weak self] in
            self?.storedData.otpType = .sms
            self?.getOTP()
        }
        otpMethodController.didChoseWhatsapp = { [weak self] in
            self?.storedData.otpType = .whatsapp
            self?.getOTP()
        }
        otpMethodController.modalPresentationStyle = .fullScreen
        present(otpMethodController, animated: true)
    }
}

// MARK: Presentation
extension RegisterVerifyOTPViewController: ResourceView {
    public func display(view viewModel: RegisterVerifyOTPViewModel) {
        if viewModel.isValid {
            delegate?.complete(step: self)
        } else {
            mainView.setErrorText("Nomor sudah terdaftar")
        }
    }
}

extension RegisterVerifyOTPViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension RegisterVerifyOTPViewController: RequestOTPViewAdapterDelegate {
    func didRequestOTP(_ viewModel: RegisterRequestOTPViewModel) {
        resetCountdown(viewModel.countdownInterval)
    }
}

extension RegisterVerifyOTPViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        
        switch RegisterVerifyOTPError(rawValue: error.code) {
        case .tooManyWrongInput:
            if let retryInterval = tooManyRequestErrorOccured(errorViewModel) {
                mainView.setErrorText(error.message)
                resetCountdown(retryInterval)
                view.endEditing(true)
                return
            }
            
        case .none:
            // Request OTP
            if let retryInterval = tooManyRequestErrorOccured(errorViewModel) {
                mainView.setErrorTooManyRequest(method: storedData.otpType.desc)
                resetCountdown(retryInterval)
                view.endEditing(true)
                return
            }
            
            mainView.setErrorText(error.message)
        }
    }
    
    private func tooManyRequestErrorOccured(_ viewModel: ResourceErrorViewModel) -> Int? {
        guard let error: RegisterTooManyOTPRequestError = viewModel.error?.decodeError() else {
            return nil
        }
        let interval = error.data.expireInSecond ?? error.data.tryInSecond ?? 0
        return interval
    }
}

// MARK: UI
private extension RegisterVerifyOTPViewController {
    func configureUI() {
        view.backgroundColor = .white
        
        configureMainView()
    }
    
    func configureMainView() {
        mainView.backgroundColor = .clear
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
