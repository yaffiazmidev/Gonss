import UIKit
import Combine
import KipasKipasShared
import KipasKipasDonationHistory
import KipasKipasDonationHistoryiOS
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasLogin
import KipasKipasLoginiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var defaults = UserDefaults.standard
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKDonationHistoryApp.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private lazy var baseURL: URL = {
        let baseURL = Bundle.main.infoDictionary! ["API_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()
    
    private lazy var tokenStore: TokenStore = {
        return makeKeychainTokenStore()
    }()
    
    private lazy var httpClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).httpClient
    }()
    
    private lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).authHTTPClient
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UIFont.loadCustomFonts
        
        NotificationCenter.default.addObserver(self, selector: #selector(onShakeMotion), name: UIDevice.deviceDidShakeNotification, object: nil)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        configureRootViewController(in: window)
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func configureRootViewController(in window: UIWindow) {
        if !defaults.hasRunBefore {
            defaults.hasRun()
            tokenStore.remove()
        }
        
        if tokenStore.retrieve() == nil {
            window.rootViewController = makeLoginViewController()
        } else {
            window.rootViewController = UINavigationController(rootViewController: makeDonationHistoryViewController())
        }
    }
    
    @objc private func onShakeMotion() {
        if let window = window, tokenStore.retrieve() != nil {
            tokenStore.remove()
            configureRootViewController(in: window)
            
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        }
    }
}

private extension SceneDelegate {
    func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
    
    func makeHTTPClient(baseURL: URL) -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let localTokenLoader = LocalTokenLoader(store: tokenStore)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: localTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: tokenStore, loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
    
    func makeDonationHistoryViewController() -> DonationHistoryViewController {
        let loader = RemoteDonationHistoryLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        let viewController = DonationHistoryUIComposer.composeDonationHistoryWith(
            type: "DEBIT",
            campaignId: "402880e78aca4386018aca543c14001f",
            emptyMessage: "Belum ada dana terkumpul",
            loader: loader
        )
        viewController.title = "Riwayat Dana Terkumpul"
        return viewController
    }
}

// MARK: Login
private extension UserDefaults {
    enum Key: String {
        case hasRunBefore
    }
    
    var hasRunBefore: Bool {
        return bool(forKey: Key.hasRunBefore.rawValue)
    }
    
    func hasRun() {
        setValue(true, forKey: Key.hasRunBefore.rawValue)
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
                return .init(
                    code: mappedError.code,
                    message: mappedError.message,
                    data: mappedError.data
                )
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func setUserLoginSession(from data: LoginResponse) {
        tokenStore.insert(data.localToken) { _ in }
    }
    
    func makeLoginViewController() -> UIViewController {
        let callbacks = LoginUIComposer.Callback(
            onSuccessLogin: { [weak self] loginResponse in
                guard let self = self, let window = self.window else { return }
                self.setUserLoginSession(from: loginResponse)
                self.configureRootViewController(in: window)
            },
            onFailedLogin: { _ in }
        )
        let loginViewController = LoginUIComposer.composeLoginWith(
            publisher: makeLoginLoader,
            callbacks: callbacks,
            delegate: self
        )
        loginViewController.modalPresentationStyle = .fullScreen
        
        let featureLabel = UILabel()
        featureLabel.text = "KipasKipasDonationHistory"
        featureLabel.font = .roboto(.bold, size: 20)
        featureLabel.textAlignment = .center
        featureLabel.textColor = .watermelon
        
        loginViewController.view.addSubview(featureLabel)
        featureLabel.anchors.centerY.align(offset: 30)
        featureLabel.anchors.centerX.align()
        
        return loginViewController
    }
}

private extension LoginResponse {
    var localToken: LocalTokenItem {
        var second = expiresIn ?? 1234
        second -= 43200
        
        let expiredDate = TokenHelper.addSecondToCurrentDate(second: second)
        
        return .init(
            accessToken: accessToken ?? "",
            refreshToken: refreshToken ?? "",
            expiresIn: expiredDate
        )
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func showRegisterPage() {}
    func showForgotPasswordPage() {}
}

private extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
