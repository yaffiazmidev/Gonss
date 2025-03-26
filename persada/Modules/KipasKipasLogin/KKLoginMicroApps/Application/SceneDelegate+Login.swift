import UIKit
import Combine
import KipasKipasLogin
import KipasKipasLoginiOS
import KipasKipasShared
import KipasKipasNetworking

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var baseURL: URL = {
        let baseURL = Bundle.main.infoDictionary! ["API_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.KipasKipas.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        return URLSessionHTTPClient(session: session)
    }()
    
    lazy var navigationController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UIFont.loadCustomFonts
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let rootViewController = DemoViewController()
        navigationController.setViewControllers([rootViewController], animated: false)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        
        self.window = window
        window.makeKeyAndVisible()
        
        rootViewController.showLoginOptions = showLoginOptions
    }
}

private final class DemoViewController: UIViewController {
    
    var showLoginOptions: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Tap"
        label.textColor = .night
        
        view.addSubview(label)
        label.anchors.center.align()
        
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(onTapView))
        
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func onTapView() {
        showLoginOptions?()
    }
}

private extension SceneDelegate {
    func makeLoginLoader(_ param: LoginRequestParam) -> API<LoginResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/login")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<LoginResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(code: mappedError.code, message: mappedError.message)
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }

    func makeLoginOTPRequestLoader(_ param: LoginOTPRequestParam) -> API<LoginOTPRequestData, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/otp")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<LoginOTPRequestData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLoginViewController() -> UIViewController {
        let loaders = LoginUIComposer.Loader(
            loginLoader: makeLoginLoader
        )
        
        let callbacks = LoginUIComposer.Callback(
            onSuccessLogin: { dump($0) },
            onFailedLogin: { dump($0) }
        )
        
        let controller = LoginUIComposer.composeWith(
            account: nil,
            loaders: loaders,
            callbacks: callbacks,
            delegate: Delegation()
        )
        
        return controller
    }
    
    func makeLoginOTPRequestViewController() -> UIViewController {
        let callbacks = LoginOTPRequestUIComposer.Callback(
            onSuccessRequestOTP: navigateToLoginWithOTPViewController
        )
        
        let controller = LoginOTPRequestUIComposer.composeWith(
            publisher: makeLoginOTPRequestLoader,
            callbacks: callbacks
        )
        
        return controller
    }
    
    func makeLoginWithPasswordViewController(phoneNumber: Phone) -> UIViewController {
        let parameter = LoginPasswordUIComposer.Parameter(phoneNumber: phoneNumber)
        let events = LoginPasswordUIComposer.Event(didTapForgotPassword: {})
        let callbacks = LoginPasswordUIComposer.Callback(
            onSuccessLogin: { print("[BEKA] login success", String($0.token?.prefix(8) ?? "No token")) },
            onFailedLogin: { print("[BEKA] login error", $0)}
        )
        let controller = LoginPasswordUIComposer.composeWith(
            loader: makeLoginLoader,
            parameter: parameter,
            events: events,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeLoginWithOTPViewController(parameter: LoginWithOTPUIComposer.Parameter) -> UIViewController {
        let loaders = LoginWithOTPUIComposer.Loader(
            loginLoader: makeLoginLoader,
            otpRequestLoader: makeLoginOTPRequestLoader
        )
        
        let event = LoginWithOTPUIComposer.Event(
            onTapRegister: { _ in }, 
            didTapLoginWithPassword: navigateToLoginWithPasswordViewController
        )
        
        let callback = LoginWithOTPUIComposer.Callback(
            onSuccessLogin: { _ in }
        )
        
        let controller = LoginWithOTPUIComposer.composeWith(
            loaders: loaders,
            parameter: parameter,
            event: event,
            callback: callback
        )
        return controller
    }
}

// MARK: Routing
extension SceneDelegate {
    func showLoginOptions() {
        let loginOptions = LoginOptionsViewController()
        loginOptions.didTapLogin = navigateToLoginContainerViewController
        
        let navigationController = PanNavigationViewController(rootViewController: loginOptions)
        window?.topViewController?.presentPanModal(navigationController)
    }
    
    func navigateToLoginWithOTPViewController(_ phone: Phone, _ interval: TimeInterval) {
        let destination = makeLoginWithOTPViewController(parameter: .init(phoneNumber: phone, interval: interval))
        window?.topNavigationController?.pushViewController(destination, animated: false)
    }
    
    func navigateToLoginContainerViewController() {
        let destination = LoginContainerViewController(
            models: [
                .init(viewController: makeLoginOTPRequestViewController(), title: "Telepon"),
                .init(viewController: makeLoginViewController(), title: "Alamat email/nama pengguna")
            ]
        )
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
    
    func navigateToLoginWithPasswordViewController(phoneNumber: Phone) {
        let destination = makeLoginWithPasswordViewController(phoneNumber: phoneNumber)
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
}

extension UIWindow {
    var topNavigationController: UINavigationController?  {
        return topViewController?.navigationController
    }
    
    private class func topViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let top = topViewController(nav.visibleViewController)
            return top
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                let top = topViewController(selected)
                return top
            }
        }
        
        if let presented = base?.presentedViewController {
            let top = topViewController(presented)
            return top
        }
        return base
    }
    
    var topViewController: UIViewController? {
        return UIWindow.topViewController(rootViewController)
    }
}

private class Delegation: LoginViewControllerDelegate {
    func showRegisterPage() {}
    func showForgotPasswordPage() {}
}
