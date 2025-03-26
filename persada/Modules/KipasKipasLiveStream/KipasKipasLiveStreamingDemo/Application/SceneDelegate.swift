import UIKit
import Combine
import KipasKipasLiveStream
import KipasKipasLiveStreamiOS
import KipasKipasLogin
import KipasKipasLoginiOS
import KipasKipasNetworking
import KipasKipasShared
import KipasKipasTRTC
import TUICore
import ImSDK_Plus

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private(set) lazy var defaults = UserDefaults.standard
        
    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKLiveStreamingMicroApps.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var baseURL: URL = {
        let baseURL = Bundle.main.infoDictionary! ["API_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()
    
    private(set) lazy var tokenStore: TokenStore = {
        return KeychainTokenStore()
    }()
    
    private(set) lazy var loggedInUserStore: LoggedUserKeychainStore = {
        return LoggedUserKeychainStore()
    }()
    
    private(set) lazy var httpClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).httpClient
    }()
    
    private(set) lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).authHTTPClient
    }()
    
    private lazy var dummyViewController: DummyViewController = {
        let dummy = DummyViewController()
        dummy.delegate = self
        return dummy
    }()
    
    private lazy var navigationController = UINavigationController(rootViewController: dummyViewController)
    
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
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
    
    func configureRootViewController(in window: UIWindow) {
//        window.rootViewController = makeLoginViewController()
        
        
        if !defaults.hasRunBefore {
            defaults.hasRun()
        }
        
        let storedToken = tokenStore.retrieve()
        
        guard storedToken != nil else {
            window.rootViewController = makeLoginViewController()
            return
        }
        
        window.rootViewController = navigationController
    }
    
    @objc private func onShakeMotion() {
        if let window = window, tokenStore.retrieve() != nil {
            defaults.removeObject(forKey: "hasRunBefore")
            tokenStore.remove()
            loggedInUserStore.remove()
            configureRootViewController(in: window)
            
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
        }
    }
    
    func saveUserLoggedIn(from response: LoginResponse) {
        let user = LoggedInUser(
            role: response.role ?? "",
            userName: response.userName ?? "",
            userEmail: response.userEmail ?? "",
            userMobile: response.userMobile ?? "",
            accountId: response.accountID ?? ""
        )
        
        loggedInUserStore.insert(user) { _ in }
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


extension SceneDelegate: DummyDelegate {
    func didClickAnchor() {
        let anchor = makeLiveStreamingAnchorViewController()
        anchor.modalPresentationStyle = .fullScreen
        window?.topViewController?.present(anchor, animated: true)
    }
    
    func didClickLiveStreamingList() {
        let list = makeLiveStreamingListViewController()
        window?.topNavigationController?.pushViewController(list, animated: true)
    }
    
    func didClickDailyRanking() {
        let dailyRanking = makeDailyRankViewController(true)
        let navigation = PanNavigationViewController(rootViewController: dailyRanking)
        window?.topNavigationController?.presentPanModal(navigation)
    }
    
    func didClickGift() {
        let listGift = makeListGiftViewController()
        let navigation = PanNavigationViewController(rootViewController: listGift)
        window?.topNavigationController?.presentPanModal(navigation)
    }
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
