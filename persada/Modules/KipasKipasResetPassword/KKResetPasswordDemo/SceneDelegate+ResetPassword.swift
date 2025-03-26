import UIKit
import KipasKipasShared
import KipasKipasSharedFoundation
import KipasKipasNetworking
import KipasKipasResetPassword
import KipasKipasResetPasswordiOS

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
    
    private lazy var navigationController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UIFont.loadCustomFonts
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let rootViewController = DemoViewController()
        navigationController.setViewControllers([rootViewController], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
        
        rootViewController.showRootViewController = navigateToResetPasswordWithEmailViewController
    }
}

private final class DemoViewController: UIViewController, NavigationAppearance {
    
    var showRootViewController: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
    }
    
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
        showRootViewController?()
    }
}

// MARK: Loaders
private extension SceneDelegate {
    func makeResetPasswordRequestOTPLoader(_ param: ResetPasswordRequestOTPParam) -> API<ResetPasswordOTPData, AnyError> {
        let isMail = param.email != nil
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password\(isMail ? "/mail" : "")/request")
                    .method(.POST)
                    .body(param.email ?? param.phone)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordOTPData>.map)
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
    
    func makeResetPasswordVerifyOTPLoader(_ param: ResetPasswordVerifyOTPParam) -> API<ResetPasswordVerifyOTPData, AnyError> {
        let isMail = param.email != nil
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password/verify/\(isMail ? "mail" : "otp")")
                    .method(.POST)
                    .body(param.email ?? param.phone)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordVerifyOTPData>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeResetPasswordLoader(_ param: ResetPasswordVerifyOTPResponse) -> API<ResetPasswordResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/forgot-password")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(
                    code: mappedError.code,
                    message: mappedError.message
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLoginLoader(_ param: ResetPasswordLoginParam) -> API<ResetPasswordLoginResponse, AnyError> {
        return httpClient
            .getPublisher(
                request: .url(baseURL)
                    .path("/auth/login")
                    .method(.POST)
                    .body(param)
                    .build()
            )
            .tryMap(Mapper<ResetPasswordLoginResponse>.map)
            .mapError({ error in
                let mappedError = MapperError.map(error)
                return AnyError(code: mappedError.code, message: mappedError.message)
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

// MARK: View-controller factory
private extension SceneDelegate {
    func makeResetPasswordWithPhoneViewController() -> UIViewController {
        let callbacks = ResetPasswordPhoneUIComposer.Callback(
            onSuccessRequestOTP: navigateToResetPasswordVerifyOTPViewController
        )
        
        let controller = ResetPasswordPhoneUIComposer.composeWith(
            loader: makeResetPasswordRequestOTPLoader,
            callbacks: callbacks
        )
        return controller
    }
    
    func makeResetPasswordVerifyOTPViewController(param: ResetPasswordParameter) -> UIViewController {
        
        let loaders = ResetPasswordVerifyOTPUIComposer.Loader(
            verifyOTPLoader: makeResetPasswordVerifyOTPLoader,
            requestOTPLoader: makeResetPasswordRequestOTPLoader
        )
        let callback = ResetPasswordVerifyOTPUIComposer.Callback(
            onSuccessVerifyOTP: navigateToResetPasswordViewController
        )
        let controller = ResetPasswordVerifyOTPUIComposer.composeWith(
            loaders: loaders,
            parameter: param,
            callback: callback
        )
        
        return controller
    }
    
    func makeResetPasswordViewController(param: ResetPasswordUIComposer.Parameter) -> UIViewController {
        let loaders = ResetPasswordUIComposer.Loader(
            resetPasswordLoader: makeResetPasswordLoader,
            loginLoader: makeLoginLoader
        )
        let callback = ResetPasswordUIComposer.Callback(
            onSuccessLogin: { response in
                print("[BEKA] success login",  response)
            },
            onFailedLogin: {
                print("[BEKA] failed login")
            }
        )
        let controller = ResetPasswordUIComposer.composeWith(
            loaders: loaders,
            parameter: param,
            callback: callback
        )
        
        return controller
    }
    
    func makeResetPasswordEmailViewController() -> UIViewController {
        let callbacks = ResetPasswordEmailUIComposer.Callback(
            onSuccessRequestOTP: navigateToResetPasswordVerifyOTPViewController
        )
        let controller = ResetPasswordEmailUIComposer.composeWith(
            loader: makeResetPasswordRequestOTPLoader,
            callbacks: callbacks
        )
        return controller
    }
}

// MARK: Routing
private extension SceneDelegate {
    func navigateToResetPasswordWithPhoneViewController() {
        let destination = makeResetPasswordWithPhoneViewController()
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
    
    func navigateToResetPasswordWithEmailViewController() {
        let destination = makeResetPasswordEmailViewController()
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
    
    func navigateToResetPasswordVerifyOTPViewController(param: ResetPasswordParameter) {
        let destination = makeResetPasswordVerifyOTPViewController(param: param)
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
    
    func navigateToResetPasswordViewController(_ response: ResetPasswordVerifyOTPResponse) {
        let destination = makeResetPasswordViewController(param: .init(response: response))
        window?.topNavigationController?.pushViewController(destination, animated: true)
    }
}

#warning("[BEKA] can be reusable. Should move this to a shared scope")
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

