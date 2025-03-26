import UIKit
import KipasKipasDonationTransactionDetail
import KipasKipasNotificationiOS
import KipasKipasNetworking
import KipasKipasLogin
import KipasKipasLoginiOS
import Combine
import KipasKipasNotification
import KipasKipasShared
import KipasKipasDirectMessage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private(set) lazy var defaults = UserDefaults.standard
    
    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKNotificationApps.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var baseURL: URL = {
        let stringUrl = Bundle.main.infoDictionary!  ["API_BASE_URL"] as! String
        return URL(string: stringUrl)!
    }()
    
    private lazy var sendBirdAppId: String = {
        return Bundle.main.infoDictionary!["SENDBIRD_APP_ID"] as! String
    }()
   
    private(set) lazy var toolsBaseUrl: URL = {
        let stringUrl = Bundle.main.infoDictionary!  ["API_TOOLS_BASE_URL"] as! String
        return URL(string: stringUrl)!
    }()
    
    private lazy var dummyViewController: ViewController = {
        let dummy = ViewController()
        dummy.activitiesLoader = activitiesLoader
        dummy.profileStoryLoader = profileStoryLoader
        dummy.storyLoader = storyLoader
        dummy.followersLoader = followersLoader
        dummy.suggestionAccountLoader = suggestionAccountLoader
        dummy.systemNotifLoader = systemNotifLoader
        dummy.transactionLoader = transactionLoader
        dummy.activitiesDetailLoader = activitiesDetailLoader
        return dummy
    }()
   
    private lazy var dummySystemController: UIViewController = {
        let events = NotificationSystemUIComposer.EventsNotification { [weak self] types in
           print("noor testing click")
        } showFeed: { [weak self] feedId in
           print("noor testing click")
        }

        let controller = NotificationSystemUIComposer.composeNotificationSystemWith(emptyMessage: "belum ada notif", loader: systemNotifLoader, events: events)
        return controller
    }()
    
    private func dummyContentController(types: String) -> UIViewController {
        let controller = NotificationSystemContentUIComposer.composeNotificationSystemWith(types: types, emptyMessage: "belumda ada notif", loader: systemNotifLoader, showFeed: {_ in 
            print("noor testing navigate feed")
        })
        return controller
    }
    
    private lazy var activitiesLoader: NotificationActivitiesLoader = {
        let loader: NotificationActivitiesLoader = RemoteNotificationActivitiesLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var systemNotifLoader: NotificationSystemLoader = {
        let loader: NotificationSystemLoader = RemoteNotificationSystemLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var profileStoryLoader: NotificationProfileStoryLoader = {
        let loader: NotificationProfileStoryLoader = RemoteNotificationProfileStoryLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var followersLoader: NotificationFollowersLoader = {
        let loader: NotificationFollowersLoader = RemoteNotificationFollowersLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var transactionLoader: NotificationTransactionLoader = {
        let loader: NotificationTransactionLoader = RemoteNotificationTransactionLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var storyLoader: NotificationStoryLoader = {
        let loader: NotificationStoryLoader = RemoteNotificationStoryLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var activitiesDetailLoader: NotificationActivitiesDetailLoader = {
        let loader: NotificationActivitiesDetailLoader = RemoteNotificationActivitiesDetailLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var suggestionAccountLoader: NotificationSuggestionAccountLoader = {
        let loader: NotificationSuggestionAccountLoader = RemoteNotificationSuggestionAccountLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    // MARK: Dummy loader
    private lazy var dummySystemNotifLoader: NotificationSystemLoader = {
        let loader: NotificationSystemLoader = RemoteNotificationSystemLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var dummyTransactionLoader: NotificationTransactionLoader = {
        let loader: NotificationTransactionLoader = RemoteNotificationTransactionLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var followUserLoader: NotificationFollowUserLoader = {
        let loader: NotificationFollowUserLoader = RemoteNotificationFollowUserLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var isReadChecker: NotificationActivitiesIsReadCheck = {
        let loader: NotificationActivitiesIsReadCheck = RemoteNotificationActivitiesIsReadCheck(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var preferencesLoader: NotificationPreferencesLoader = {
        let loader: NotificationPreferencesLoader = RemoteNotificationPreferencesLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var preferencesUpdater: NotificationPreferencesUpdater = {
        let loader: NotificationPreferencesUpdater = RemoteNotificationPreferencesUpdater(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private lazy var transactionDetailLoader: NotificationTransactionDetailLoader = {
        let loader: NotificationTransactionDetailLoader = RemoteNotificationTransactionDetailLoader(url: baseURL, client: authenticatedHTTPClient)
        return loader
    }()
    
    private(set) lazy var donationOrderLoader: DonationTransactionDetailOrderLoader = { [self] in
        let loader = RemoteDonationTransactionDetailOrderLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private(set) lazy var donationGroupLoader: DonationTransactionDetailGroupLoader = { [self] in
        let loader = RemoteDonationTransactionDetailGroupLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private(set) lazy var isReadSystemChecker: NotificationSystemIsReadCheck = { [self] in
        let loader = RemoteNotificationSystemIsReadCheck(url: baseURL, client: authenticatedHTTPClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private(set) lazy var notificationUnreadLoader: NotificationUnreadLoader = { [self] in
        let loader = RemoteNotificationUnreadLoader(baseURL: baseURL, client: authenticatedHTTPClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    
    private(set) lazy var notificationReadUpdater: NotificationReadUpdater = { [self] in
        let loader = RemoteNotificationReadUpdater(baseURL: baseURL, client: authenticatedHTTPClient)
        return MainQueueDispatchDecorator(decoratee: loader)
    }()
    
    private lazy var navigationController = UINavigationController(rootViewController: dummyViewController)
    
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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UIFont.loadCustomFonts
        NotificationCenter.default.addObserver(self, selector: #selector(onShakeMotion), name: UIDevice.deviceDidShakeNotification, object: nil)
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        SendbirdSDKEnvUseCase.initialize(appId: sendBirdAppId)
        
        let window = UIWindow(windowScene: windowScene)
        configureRootViewController(in: window)
        window.makeKeyAndVisible()
        self.window = window
    }

    func configureRootViewController(in window: UIWindow) {
        
        if !defaults.hasRunBefore {
            defaults.hasRun()
        }
//        
        let storedToken = tokenStore.retrieve()
//        
        guard storedToken != nil else {
            window.rootViewController = makeLoginViewController()
            return
        }
//        
//        dummyViewController.id = loggedInUserStore.retrieve()?.accountId ?? ""
        let vc = NotificationRouter.create(
            followersLoader: MainQueueDispatchDecorator(decoratee: followersLoader),
            systemNotifLoader: MainQueueDispatchDecorator(decoratee: systemNotifLoader),
            transactionLoader: MainQueueDispatchDecorator(decoratee: transactionLoader),
            suggestionAccountLoader: MainQueueDispatchDecorator(decoratee: suggestionAccountLoader),
            activitiesLoader: MainQueueDispatchDecorator(decoratee: activitiesLoader),
            followUserLoader: MainQueueDispatchDecorator(decoratee: followUserLoader),
            storyLoader: MainQueueDispatchDecorator(decoratee: storyLoader),
            profileStoryLoader: MainQueueDispatchDecorator(decoratee: profileStoryLoader), 
            isReadChecker: MainQueueDispatchDecorator(decoratee: isReadChecker), 
            activitiesDetailLoader: MainQueueDispatchDecorator(decoratee: activitiesDetailLoader),
            preferencesLoader: MainQueueDispatchDecorator(decoratee: preferencesLoader),
            preferencesUpdater: MainQueueDispatchDecorator(decoratee: preferencesUpdater), 
            transactionDetailLoader: MainQueueDispatchDecorator(decoratee: transactionDetailLoader),
            donationOrderLoader: MainQueueDispatchDecorator(decoratee: donationOrderLoader),
            donationGroupLoader: MainQueueDispatchDecorator(decoratee: donationGroupLoader),
            isReadSystemChecker: MainQueueDispatchDecorator(decoratee: isReadSystemChecker),
            unreadsLoader: MainQueueDispatchDecorator(decoratee: notificationUnreadLoader),
            readUpdater: MainQueueDispatchDecorator(decoratee: notificationReadUpdater),
            handleShowConversation: nil,
            handleShowStory: nil,
            handleShowMyStory: nil,
            handleShowUserProfile: nil,
            handleShowFeed: nil, 
            handleShowAddStory: nil, 
            handleShowSingleFeed: nil, 
            handleShowLive: nil,
            handleShowCurrencyDetail: nil,
            handleShowWithdrawlDetail: nil,
            handleShowDonationGroupOrder: nil
        )
        vc.loggedUserId = loggedInUserStore.retrieve()?.accountId ?? ""
        window.rootViewController = UINavigationController(rootViewController: vc)
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


extension MainQueueDispatchDecorator: NotificationActivitiesLoader where T == NotificationActivitiesLoader {
    public func load(request: NotificationActivitiesRequest, completion: @escaping (ResultActivities) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationFollowersLoader where T == NotificationFollowersLoader {
    public func load(request: NotificationFollowersRequest, completion: @escaping (ResultFollowers) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationTransactionLoader where T == NotificationTransactionLoader {
    public func load(request: NotificationTransactionRequest, completion: @escaping (NotificationTransactionLoader.ResultTransaction) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

//extension MainQueueDispatchDecorator: NotificationSystemLoader where T == NotificationSystemLoader {
//    public func load(request: NotificationSystemRequest, completion: @escaping (ResultSystem) -> Void) {
//        decoratee.load(request: request) { [weak self] result in
//            self?.dispatch { completion(result) }
//        }
//    }
//}

extension MainQueueDispatchDecorator: NotificationSuggestionAccountLoader where T == NotificationSuggestionAccountLoader {
    public func load(request: NotificationSuggestionAccountRequest, completion: @escaping (ResultSuggestionAccount) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationStoryLoader where T == NotificationStoryLoader {
    public func load(request: NotificationStoryRequest, completion: @escaping (ResultStory) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationProfileStoryLoader where T == NotificationProfileStoryLoader {
    public func load(request: NotificationProfileStoryRequest, completion: @escaping (ResultProfileStory) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationFollowUserLoader where T == NotificationFollowUserLoader {
    public func load(request: NotificationFollowUserRequest, completion: @escaping (ResultFollowUser) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationActivitiesIsReadCheck where T == NotificationActivitiesIsReadCheck {
    public func check(request: KipasKipasNotification.NotificationActivitiesIsReadRequest, completion: @escaping (ResultActivitiesIsRead) -> Void) {
        decoratee.check(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationPreferencesLoader where T == NotificationPreferencesLoader {
    public func load(request: NotificationPreferencesRequest, completion: @escaping (ResultPreferences) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: KipasKipasNotification.NotificationPreferencesUpdater where T == KipasKipasNotification.NotificationPreferencesUpdater {
    public typealias Result = KipasKipasNotification.NotificationPreferencesUpdater.Result
    public func update(request: KipasKipasNotification.NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void) {
        decoratee.update(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationTransactionDetailLoader where T == NotificationTransactionDetailLoader {
    public func load(request: NotificationTransactionDetailRequest, completion: @escaping (NotificationTransactionDetailLoader.ResultTransaction) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
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



extension MainQueueDispatchDecorator: NotificationActivitiesDetailLoader where T == NotificationActivitiesDetailLoader {
    public func load(request: KipasKipasNotification.NotificationActivitiesDetailRequest, completion: @escaping (ResultActivitiesDetail) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationSystemIsReadCheck where T == NotificationSystemIsReadCheck {
    public func check(request: NotificationSystemIsReadRequest, completion: @escaping (ResultSystemIsRead) -> Void) {
        decoratee.check(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationUnreadLoader where T == NotificationUnreadLoader {
    public func load(completion: @escaping (NotificationUnreadLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationReadUpdater where T == NotificationReadUpdater {
    public func update(_ request: NotificationReadRequest, completion: @escaping (NotificationReadUpdater.Result) -> Void) {
        decoratee.update(request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
