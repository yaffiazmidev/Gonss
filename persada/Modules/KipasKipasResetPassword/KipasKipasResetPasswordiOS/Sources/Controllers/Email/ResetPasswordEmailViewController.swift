import UIKit
import KipasKipasResetPassword
import KipasKipasShared
import KipasKipasSharedFoundation

public final class ResetPasswordEmailViewController: UIViewController, NavigationAppearance {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = ResetPasswordEmailView()
    
    private var emailShortcutViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            emailShortcutViewBottomConstraint.isActive = true
        }
    }
    
    private lazy var emailShortcutView: KBSegmentedDynamicTab = {
        let tab = KBSegmentedDynamicTab(
            size: .init(width: view.bounds.width, height: 27),
            position: 0
        )
        tab.layout.layoutHeight = 27
        tab.layout.contentInsets.leading = 12
        tab.layout.contentInsets.trailing = 12
        tab.layout.spacing = 12
        tab.delegate = self
        return tab
    }()
    
    private var keyboardHandler: KeyboardHandler?
    
    private var email: String = ""
    
    var requestOTP: Closure<ResetPasswordRequestOTPParam>?
    var onSuccessRequestOTP: Closure<ResetPasswordParameter>?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "Reset", backIndicator: .iconChevronLeft)
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
        setEmailShortcutData()
    }
    
    deinit {
        keyboardHandler?.unsubscribe()
    }
    
    // MARK: Helpers
    private func observe() {
        mainView.didTapReset = { [weak self] emailText in
            guard let self = self else { return }
            view.endEditing(true)
            email = emailText
            getOTP()
        }
        
        configureKeyboardObserver()
    }
    
    private func setEmailShortcutData() {
        let emails = [
            "@gmail.com",
            "@yahoo.com",
            "@outlook.com",
            "@hotmail.com",
            "@icloud.com"
        ]
        emailShortcutView.addItems(emails.map { .init(title: $0) })
    }
    
    private func getOTP() {
        requestOTP?(.init(email: .init(
            email: email,
            deviceId: deviceId
        )))
    }
}

extension ResetPasswordEmailViewController: ResourceView {
    public func display(view viewModel: ResetPasswordOTPRequestViewModel) {
        onSuccessRequestOTP?(.init(
            type: .email(email),
            countdown: viewModel.countdownInterval
        ))
    }
}

extension ResetPasswordEmailViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension ResetPasswordEmailViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        
        if tooManyRequestErrorOccured(error) {
            mainView.showRequestedTooManyOTPError()
            view.endEditing(true)
            return
        }
        
        let errorText = ResetPasswordEmailError.errorText(
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

extension ResetPasswordEmailViewController: KBTabViewDelegate {
    public func didSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) {
        mainView.addEmailExtension(item.title)
    }
    
    public func shouldSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: Keyboard Handling
private extension ResetPasswordEmailViewController {
    func configureKeyboardObserver() {
        keyboardHandler = KeyboardHandler(with: weakify(
            self, ResetPasswordEmailViewController.handleKeyboard
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
        let viewHeight = emailShortcutView.frame.size.height
        let keyboardY = height - (viewHeight / 2)
        
        if emailShortcutViewBottomConstraint.constant == 0 {
            emailShortcutViewBottomConstraint.constant = -keyboardY
        }
    }
    
    func resetViewPosition() {
        if emailShortcutViewBottomConstraint.constant < 0 {
            emailShortcutViewBottomConstraint.constant = 0
        }
    }
}

// MARK: UI
private extension ResetPasswordEmailViewController {
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = .init(image: .iconCircleQuestion, style: .plain, target: nil, action: nil)
        
        configureScrollContainer()
        configureMainView()
        configureEmailShortcutView()
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
    
    func configureEmailShortcutView() {
        emailShortcutViewBottomConstraint = wrapWithBottomSafeAreaPaddingView(emailShortcutView, color: .clear)
        emailShortcutView.anchors.edges.pin(axis: .horizontal)
        emailShortcutView.anchors.height.equal(27)
    }
}
