import UIKit
import KipasKipasDirectMessageUI
import KipasKipasDirectMessage
import KipasKipasCall
import KipasKipasShared
import KipasKipasNetworking

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private(set) lazy var defaults = UserDefaults.standard
    
    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKDirectMessage.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var baseURL: URL = {
        let baseURL = Bundle.main.infoDictionary! ["API_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()
    
    private(set) lazy var oneSignalApiKey: String = {
        return Bundle.main.infoDictionary!["ONE_SIGNAL_API_KEY"] as! String
    }()
    
    private(set) lazy var oneSignalAppId: String = {
        return Bundle.main.infoDictionary!["ONE_SIGNAL_APPID"] as! String
    }()
    
    private(set) lazy var tokenStore: TokenStore = {
        return KeychainTokenStore()
    }()
    
    private(set) lazy var httpClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).httpClient
    }()
    
    private(set) lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).authHTTPClient
    }()
    
    private(set) lazy var callAuthenticator: CallAuthenticator = {
        let auth = TUICallAuthenticator()
        return MainQueueDispatchDecorator(decoratee: auth)
    }()
    
    private(set) lazy var callLoader: CallLoader = {
        let loader = TUICallLoader()
        let decorator = CallLoaderAuthDecorator(decoratee: loader, auth: callAuthenticator)
        return MainQueueDispatchDecorator(decoratee: decorator)
    }()
    
    private(set) lazy var serviceManager: DirectMessageCallServiceManager = .instance
    
    private lazy var sendBirdAppId: String = {
        return Bundle.main.infoDictionary!["SENDBIRD_APP_ID"] as! String
    }()
    
    private(set) lazy var oneSignalBaseURL: URL = {
        let baseURL = Bundle.main.infoDictionary!["ONE_SIGNAL_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()
    
    private(set) lazy var loggedInUserStore: LoggedUserKeychainStore = {
        return LoggedUserKeychainStore()
    }()
        
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
        UIFont.loadCustomFonts
        NotificationCenter.default.addObserver(self, selector: #selector(onShakeMotion), name: UIDevice.deviceDidShakeNotification, object: nil)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
       #warning("[BEKA] Get back to this")
        // KKCache.common.save(string: baseURL, key: .baseURL)
        SendbirdSDKEnvUseCase.initialize(appId: sendBirdAppId)
        
#if DEBUG
        OneSignalManager.shared.appId = "0d1df6cb-0793-4b1c-881a-e773dd1bf88f"
        OneSignalManager.shared.apiKey = "N2MxYWRlMzctZDE1Yy00YzRkLTk5MWEtZjEyNTUzNTQ5MTQ1"
#elseif STAGING
        OneSignalManager.shared.appId = "16b9119e-8082-41a6-828e-2a8ddbba2824"
        OneSignalManager.shared.apiKey = "ZjJlMjM1ZDAtYTNkOS00MjU5LTg2MDAtZTI2ZjViNmE4MWM0"
#else
        OneSignalManager.shared.appId = "0721e737-a447-466c-b987-c84f7fdc3d4b"
        OneSignalManager.shared.apiKey = "MWIwNWRmZDgtNTE3YS00NjRkLWE1YjMtYWI3OTJiY2JmMmE2"
#endif
        
        DirectMessageCallServiceManager.configure(
            SDKAPPID: KipasKipasDirectMessageApp.SDKAPPID,
            authenticator: callAuthenticator,
            loader: callLoader,
            requestGenerateUserSig: generateCallUserSig(userId:),
            requestLoadUserData: loadUser
        )
        
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .light
        configureRootViewController(in: window)
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func generateCallUserSig(userId: String) -> String {
        TencentUserSig.genTestUserSig(userId)
    }
    
    private func loadUser(by id: String, with token: String, onSuccess: @escaping LoadUserDataCompletion) {
        struct Root: Codable {
            let code, message: String?
            let data: RootData?
        }
        
        struct RootData: Codable {
            let id: String?
            let name: String?
            let photo: String?
            let isVerified: Bool?
        }
        
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "profile/\(id)",
            method: .get,
            headerParamaters: [
                "Authorization" : "Bearer \(token)",
                "Content-Type":"application/json"
            ]
        )
        
        let config = ApiDataNetworkConfig(baseURL: baseURL)
        let network = DefaultNetworkService(config: config)
        let service = DefaultDataTransferService(with: network)
        
        _ = service.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                print("Call Feature: Failure Load Profile")
            case .success(let response):
                print("Call Feature: Success Load Profile")
                onSuccess(response?.data?.id, response?.data?.name, response?.data?.photo)
            }
        }
    }
    
    func configureRootViewController(in window: UIWindow) {
        if !defaults.hasRunBefore {
            defaults.hasRun()
        }
        
        let storedToken = tokenStore.retrieve()
        
        guard storedToken != nil else {
            window.rootViewController = makeLoginViewController()
            return
        }
        
        let navigationController = UINavigationController(rootViewController: self.makeDirectMessageViewController())
        window.switchRootViewController(viewController: navigationController)
    }
    
    @objc private func onShakeMotion() {
        if let window = window {
            defaults.removeObject(forKey: "hasRunBefore")
            tokenStore.remove()
            loggedInUserStore.remove()
            configureRootViewController(in: window)
            
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        }
    }
}

// MARK: Networking
private extension SceneDelegate {
    func makeHTTPClient(baseURL: URL) -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        let localTokenLoader = LocalTokenLoader(store: tokenStore)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: localTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: tokenStore, loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

private extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}
