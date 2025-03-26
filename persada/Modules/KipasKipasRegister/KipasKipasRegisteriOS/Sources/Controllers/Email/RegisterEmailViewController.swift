import UIKit
import KipasKipasRegister
import KipasKipasShared
import KipasKipasSharedFoundation

public final class RegisterEmailViewController: UIViewController {
    
    private let scrollContainer = ScrollContainerView()
    private lazy var mainView = RegisterEmailView()
    
    private var emailShortcutViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            emailShortcutViewBottomConstraint.isActive = true
        }
    }
    
    private lazy var serviceWebViewController: UIViewController = {
        let url = URL(string: "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/")
        let controller = ProgressWebViewController(url: url)
        controller.title = "Syarat & Ketentuan"
        return controller
    }()
    
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
    
    private var email: String = ""
    private var keyboardHandler: KeyboardHandler?
        
    var checkAvailability: Closure<RegisterAccountAvailabilityParam>?
    var onAccountAvailable: Closure<String>?
    var onAccountNotAvailable: Closure<String>?
    
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
    
    private func observe() {
        mainView.didTapSubmit = { [weak self] emailStr in
            guard let self = self else { return }
            view.endEditing(true)
            email = emailStr
            checkAvailability?(.email(emailStr))
        }
        mainView.didTapLearnMore = { [weak self] in
            guard let self = self else { return }
            navigationController?.pushViewController(serviceWebViewController, animated: true)
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
    
    deinit {
        keyboardHandler?.unsubscribe()
    }
}

// MARK: ResourceView, ResourceLoadingView, ResourceErrorView
extension RegisterEmailViewController: ResourceView {
    public func display(view viewModel: RegisterAccountAvailabilityViewModel) {
        guard viewModel.isExists == false else {
            return
        }
        onAccountAvailable?(email)
    }
}

extension RegisterEmailViewController: ResourceLoadingView {
    public func display(loading loadingViewModel: ResourceLoadingViewModel) {
        mainView.setLoading(loadingViewModel.isLoading)
    }
}

extension RegisterEmailViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        guard let error = errorViewModel.error else { return }
        
        if error.code == "4200" {
            onAccountNotAvailable?(email)
        } else {
            mainView.setErrorText(error.message ?? "")
        }
    }
}

// MARK: KBTabViewDelegate
extension RegisterEmailViewController: KBTabViewDelegate {
    public func didSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) {
        mainView.addEmailExtension(item.title)
    }
    
    public func shouldSelectTabView(_ item: any KBTabViewItemable, at indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: UI
private extension RegisterEmailViewController {
    func configureUI() {
        view.backgroundColor = .white
        
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

// MARK: Keyboard Handling
private extension RegisterEmailViewController {
    func configureKeyboardObserver() {
        keyboardHandler = KeyboardHandler(with: weakify(
            self, RegisterEmailViewController.handleKeyboard
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
