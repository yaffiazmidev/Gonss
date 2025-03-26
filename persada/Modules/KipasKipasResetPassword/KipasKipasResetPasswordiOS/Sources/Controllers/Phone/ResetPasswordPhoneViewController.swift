import UIKit
import KipasKipasResetPassword
import KipasKipasShared
import KipasKipasSharedFoundation

public final class ResetPasswordPhoneViewController: UIViewController, NavigationAppearance {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = ResetPasswordPhoneView()
    
    private var phoneNumber: String = ""
    
    var requestOTP: Closure<ResetPasswordRequestOTPParam>?
    var onSuccessRequestOTP: Closure<ResetPasswordParameter>?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Reset", backIndicator: .iconChevronLeft)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observe()
    }
    
    private func observe() {
        mainView.didTapSubmit = { [weak self] phoneNumber in
            guard let self = self else { return }
            view.endEditing(true)
            self.phoneNumber = phoneNumber.addZeroPrefixOnPhoneNumber()
            getOTP()
        }
    }
    
    private func getOTP() {
        requestOTP?(.init(
            phone: .init(key: phoneNumber)
        ))
    }
}

extension ResetPasswordPhoneViewController: ResourceView {
    public func display(view viewModel: ResetPasswordOTPRequestViewModel) {
        onSuccessRequestOTP?(.init(
            type: .phone(phoneNumber),
            countdown: viewModel.countdownInterval
        ))
    }
}

extension ResetPasswordPhoneViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension ResetPasswordPhoneViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        
        if tooManyRequestErrorOccured(error) {
            mainView.showRequestedTooManyOTPError()
            view.endEditing(true)
            return
        }
        
        let errorText = ResetPasswordPhoneError.errorText(
            code: error.code,
            defaultMessage: error.message
        )
        mainView.setErrorText(errorText)
    }
    
    private func tooManyRequestErrorOccured(_ error: AnyError) -> Bool {
        let decodedError: ResetPasswordTooManyOTPRequestError? = error.decodeError()
        return decodedError != nil
    }
}

private extension ResetPasswordPhoneViewController {
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
        
        scrollContainer.addArrangedSubViews(spacer(32))
        scrollContainer.addArrangedSubViews(mainView)
    }
}
