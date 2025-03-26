import UIKit
import KipasKipasDonationTransactionDetailiOS
import KipasKipasDonationTransactionDetail
import KipasKipasNetworking
//import KipasKipasNetworkingUtils
import KipasKipasShared
import Inject
import Combine
import KipasKipasLogin
import KipasKipasLoginiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private(set) lazy var defaults = UserDefaults.standard
        
    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKLiveStreamingMicroApps.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var baseURL: URL = {
        let stringUrl = Bundle.main.infoDictionary!  ["API_BASE_URL"] as! String
        return URL(string: stringUrl)!
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
    
    private(set) lazy var orderLoader: DonationTransactionDetailOrderLoader = { [self] in
        let loader = RemoteDonationTransactionDetailOrderLoader(baseURL: baseURL, client: httpClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private(set) lazy var loggedInUserStore: LoggedUserKeychainStore = {
        return LoggedUserKeychainStore()
    }()
    
    private(set) lazy var groupLoader: DonationTransactionDetailGroupLoader = { [self] in
        let loader = RemoteDonationTransactionDetailGroupLoader(baseURL: baseURL, client: httpClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private(set) lazy var listController: DonationTransactionDetailController = {
        let controller = DonationTransactionDetailController(orderId: "402880dc8df9f1aa018e087bc9317a29", groupId: "CART-DONATION-7c9c9036-5dbf-4b3f-8703-6ea813f69884", events: DonationTransactionDetailController.Events(onTapPayNow: { _ in }, onTapDonateAgain: { _,_  in }))
        controller.orderLoader = orderLoader
        controller.groupLoader = groupLoader
        
        return controller
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        configureRootViewController(in: window)
        window.makeKeyAndVisible()
        
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

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
    
    func configureRootViewController(in window: UIWindow) {
        if !defaults.hasRunBefore {
            defaults.hasRun()
        }
        
        let storedToken = tokenStore.retrieve()
        
        guard storedToken != nil else {
            window.rootViewController = makeLoginViewController()
            return
        }
        
        let viewController = Inject.ViewControllerHost(UINavigationController(rootViewController: self.listController))
        window.rootViewController = viewController
    }
}

// MARK: Networking
extension SceneDelegate {
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


extension MainQueueDispatchDecorator: DonationTransactionDetailOrderLoader where T == DonationTransactionDetailOrderLoader {
    public func load(request: DonationTransactionDetailOrderRequest, completion: @escaping (DonationTransactionDetailOrderLoader.DonationTransactionDetailResult) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: DonationTransactionDetailGroupLoader where T == DonationTransactionDetailGroupLoader {
    public func load(request: DonationTransactionDetailGroupRequest, completion: @escaping (DonationTransactionDetailGroupLoader.GroupResult) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

struct LoggedInUser: Codable {
    let role: String
    let userName, userEmail, userMobile, accountId: String
    
    init(
        role: String,
        userName: String,
        userEmail: String,
        userMobile: String,
        accountId: String
    ) {
        self.role = role
        self.userName = userName
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.accountId = accountId
    }
}

final class LoggedUserKeychainStore {
    
    private var keychain: KKCaching {
        return KKCache.credentials
    }
    
    private let key: KKCache.Key = .loggedInUser
    
    typealias InsertionResult = Swift.Result<Void, Error>
   
    func insert(_ user: LoggedInUser, completion: @escaping (InsertionResult) -> Void) {
        do {
            try keychain.save(value: user, key: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func retrieve() -> LoggedInUser? {
        return try? keychain.read(type: LoggedInUser.self, key: key)
    }
    
    func remove() {
        return keychain.remove(key: key)
    }
}
