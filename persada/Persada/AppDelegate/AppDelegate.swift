import UIKit
import KipasKipasVerificationIdentityiOS
import KipasKipasVerificationIdentity
import IQKeyboardManagerSwift
import Kingfisher
import Firebase
import FeedCleeps
import KipasKipasNetworking
import KipasKipasShared
import Branch
import KipasKipasPaymentInAppPurchase
import KipasKipasTRTC
import ImSDK_Plus
import SDWebImage
import KipasKipasCall
import KipasKipasNetworkingUtils
import KipasKipasDirectMessage
import KipasKipasDonationCart
import KipasKipasImage
import KipasKipasStoryiOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var animator: JellyAnimator?
    
    lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.KipasKipas.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    lazy var baseURL: URL = {
        return URL(string: APIConstants.baseURL)!
    }()
    
    lazy var tokenLoader: RemoteTokenLoader = {
        let httpClient = makeHTTPClient(baseURL: baseURL).httpClient
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        return remoteTokenLoader
    }()
    
    lazy var tokenStore: TokenStore = {
        return makeKeychainTokenStore()
    }()
    
    lazy var blockedUserStore: BlockedUserStore = {
        return makeKeychainBlockedUserStore()
    }()
    
    lazy var httpClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).httpClient
    }()
    
    lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).authHTTPClient
    }()
    
    private(set) lazy var oneSignalApiKey: String = {
        return Bundle.main.infoDictionary!["ONE_SIGNAL_REST_API_KEY"] as! String
    }()

    private(set) lazy var oneSignalAppId: String = {
        return Bundle.main.infoDictionary!["ONE_SIGNAL_ID"] as! String
    }()

    private(set) lazy var oneSignalBaseURL: URL = {
        let baseURL = Bundle.main.infoDictionary!["ONE_SIGNAL_BASE_URL"] as! String
        return URL(string: baseURL)!
    }()

    private(set) lazy var loggedInUserStore: LoggedUserKeychainStore = {
        let store = LoggedUserKeychainStore(key: .loggedInUser)
        store.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        return store
    }()
    
    private(set) lazy var verifyIdentityStored: VerifyIdentityStoredKeychainStore = {
        return VerifyIdentityStoredKeychainStore()
    }()

    private(set) lazy var profileAdapter = {
        return LoadProfileViewAdapter(publisher: makeProfileLoader)
    }()
    
    private(set) lazy var registerAdapter = {
        return RegisterViewAdapter(publisher: makeRegisterLoader)
    }()
    
    private(set) lazy var registerVerifyEmailAdapter = {
        return RegisterVerifyEmailViewAdapter(publisher: makeVerifyEmailLoader)
    }()
    
    private(set) lazy var profileStore: ProfileKeychainStore = {
        let store = ProfileKeychainStore(key: .profile)
        store.needAuth = { [weak self] in
            self?.profileAdapter.loadProfile(
                getIdUser(),
                onSuccessLoadProfile: { [weak self] profile in
                    self?.profileStore.insert(profile)
                    self?.configureCallFeature()
//                    self?.updateSendbirdMetadata()
                    KKCache.credentials.save(string: profile.photo ?? "", key: .userPhotoProfile)
                },
                onFailedLoadProfile: { _ in })
        }
        return store
    }()
    
    private(set) lazy var imManager: V2TIMManager = {
        return V2TIMManager.sharedInstance()
    }()
    
    private(set) lazy var mediaUploader: MediaUploader = {
        return MainQueueDispatchDecorator(decoratee: MediaUploadManager())
    }()
    
    var isAuthenticated: Bool {
        return tokenStore.retrieve() != nil
    }
    
    lazy var pushNotifManager: PushNotificationManager = {
        let manager = PushNotificationManager()
        manager.delegate = self
        return manager
    }()
    
    lazy var universalLinkManager: UniversalLinkManager = {
        return UniversalLinkManager(delegate: self)
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

    private(set) lazy var callProfileLoader: CallProfileDataLoader = {
        return RemoteCallProfileDataLoader(url: baseURL, client: authenticatedHTTPClient)
    }()

    private(set) lazy var serviceManager: DirectMessageCallServiceManager = .instance
    private(set) lazy var toolsBaseUrl: URL = {
        let stringUrl = Bundle.main.infoDictionary!  ["API_TOOLS_BASE_URL"] as! String
        return URL(string: stringUrl)!
    }()
    
    // Story
    var storyProperties: [StoryProperty] = []
    
    private(set) lazy var storyUploader: StoryUploadInteractorAdapter = {
        return StoryUploadInteractorAdapter(uploader: makeStoryUploader)
    }()

    private func setBuglyParmaeter () {
//           DispatchQueue.global().async {
//           let config = BuglyConfig.init()
//           var development : Bool = false
//           #if DEBUG
//           config.debugMode = true
//           development = true
//           config.blockMonitorEnable = true;
//           config.blockMonitorTimeout = 1.5;
//           #else
//           development = false
//           #endif
//           config.unexpectedTerminatingDetectionEnable = true;
//           config.reportLogLevel = .warn
//               Bugly.start(withAppId:"200eb20b5e",developmentDevice:development,config: config)
//               if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
//                   Bugly.updateAppVersion(version)
//               }
//           }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.makeKeyAndVisible()
//        window.rootViewController = ShopUIFactory.create(isPublic: true)
//        self.window = window
        
        setBuglyParmaeter()
        UIFont.loadCustomFonts
        Branch.setUseTestBranchKey(true)
        UIView.swizzleLayoutSubviews()
        try? VideoCacheManager.cleanAllCache()
        /* KipasKipasImage */
        ImageURLSession.observe()
        
        var cache = ImageCacheSettings()
        cache.cacheExpirationTime = 300
        
        ImageDownloadSettings.requestSettings.maximumSimultaneousDownloads = 20
        ImageDownloadSettings.requestSettings.cacheSettings = cache
        
        /* ***** */
        
        UIApplication.shared.isIdleTimerDisabled = true
        //Branch.getInstance().checkPasteboardOnInstall()
        
        // check if pasteboard toast will show
        //        if Branch.getInstance().willShowPasteboardToast(){
        //            // devlopers can notify the user of what just occurred here if they choose
        //            print("== BRANCH == ", ".. willShowPasteboardToast")
        //
        //        }
        KKLogFile.instance.log(label:"AppDelegate", message: "============================================")
        KKLogFile.instance.log(label:"AppDelegate", message: "==========       START APP     =============")
        
        let username = getUsername()
        
        KKLogFile.instance.log(label:"AppDelegate", message: "Username  : \(username)")
        
        KKLogFile.instance.log(label:"AppDelegate", message: "Installed : \(KKRuntimeEnvironment.instance.type.rawValue.uppercased())")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            KKLogFile.instance.log(label:"AppDelegate", message: "Version   : \(version)")
        }
        KKLogFile.instance.log(label:"AppDelegate", message: "============================================")

        //clearCacheTUI()
        
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            var reffCode = ""
            
            print("== BRANCH == ", params as? [String: AnyObject] ?? {})
            
            if let paramsArray = params as? [String: AnyObject]{
                
                paramsArray.forEach { (key: String, value: AnyObject) in
                    //print("== BRANCH == key ", "key:\(key)" , "value:\(value as? String ?? "")")
                    if(key == "reff"){
                        if let valueString = value as? String {
                            reffCode = valueString
                        }
                    }
                }
            }
            
            if(reffCode != ""){
                print("== BRANCH == found reff :", reffCode)
                DataCache.instance.write(string: reffCode, forKey: "REFFCODE")
            }
        }
        
        let code = DataCache.instance.readString(forKey: "REFFCODE")
        print("AppDelegate - Referral Code: \(code)")
        
        //not real Jira ticket, just numbering to run once every update
        // pattern : PE-{mm/dd} , mm/dd is when this version UP to remember easily
        self.updateOnce(JIRA_TICKET: "PE-0604")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFailToRefreshToken(_:)), name: .refreshTokenFailedToComplete, object: nil)
        dealWithkeyboard()
        updateKeychainStoreIfDiskTokenNotEmpty()

        KKCache.common.save(string: baseURL.absoluteString, key: .baseURL)
        KKCache.common.save(integer: 0, key: .unreadNotificationCount(getIdUser()))
        KKCache.credentials.save(string: getIdUser(), key: .userId)
        KKCache.credentials.save(string: getPhotoURL(), key: .userPhotoProfile)
        configureFeatures()
        
        
        URLCache.shared.removeAllCachedResponses()
        clearSDWebImageExpiredCache()
//        URLCache.shared.diskCapacity = 0
//        URLCache.shared.memoryCapacity = 0
        
        //KKTencentVideoPlayerPreload.instance.clear()
        
        
        //KKResourceLoader.instance.removeAllCache()
        VerifyIdentityLoaderFactory.shared.setClient(
            baseURL: baseURL,
            toolsURL: toolsBaseUrl,
            httpClient: httpClient,
            authHTTPClient: authenticatedHTTPClient
        )
        
        refreshToken { [weak self] in
            guard let self = self else { return }
            
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.keyboardDistanceFromTextField = -15
            
            FirebaseApp.configure()
            
            self.handleDidFinishLaunchingWithOptions(launchOptions: launchOptions)
            
            //KKWebServerFeedCleeps.shared.start()
            //                ProxyServer.shared.start()
            
            //KingfisherManager.shared.cache.memoryStorage.config.countLimit = 50
            KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 10 * 1024 * 1024 // 10 Mega
            
            
            // ALERT !!, comment / remove before MERGE, this to prevent cache (debug only)
            //DataCache.instance.cleanAll()
            //FeedSeenCache.instance.removeAllSeenFeed()
        }
        
        if tokenStore.retrieve() != nil {
            InAppPurchasePendingManager.instance.initialize(baseUrl: baseURL, userId: getIdUser(), client: authenticatedHTTPClient)
            DonationCartManager.instance.login(user: getIdUser())
        }
        
        return true
    }
    
    private func configureFeatures() {
        loadProfile()
        
        configureLoginFeature()
        configureReportFeature()
        configureDonationRankAndBadgeFeature()
        configureDonationHistoryFeature()
        configureUserBasicInfoFeature()
        configureLiveStreamingAudienceFeature()
        configureURLSchemesFeature()
        configureNewsPortal()
        configureCallFeature()
        configureVoIP()
        configureDirectMessageFeature()
        configureThirdPartyFeature()
        configureDonateStuffFeature()
        configureDonationTransacationDetailFeature()
        configureDonationCartFeature()
        configureCameraFeature()
        configureNotificationFeature()
        configureStoryFeature()
        configureVerifyIdentityFeature()
        configureExploreFeature()
    }
  
    private func loadProfile() {
        if isAuthenticated {
            if let accountId = loggedInUserStore.retrieve()?.accountId {
                profileAdapter.loadProfile(
                    accountId,
                    onSuccessLoadProfile: { [weak self] profile in
                        self?.profileStore.insert(profile)
//                        self?.updateSendbirdMetadata()
                    },
                    onFailedLoadProfile: { _ in })
            }
        }
    }
    
    func cleanFiles(){
        
        DataCache.instance.cleanAll()
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs // where fileURL.pathExtension == "mp3"
            {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  { print(error) }
        
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        URLSchemes.instance.application(open: url)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let userInfoExtracted = extractUserInfo(userInfo: userInfo)
        
        print("**** notif A")
        let payload = userInfo
        let customObject = payload["custom"] as? [String: AnyObject]
        
        if let object = customObject?["a"] as? [String: Any] {
            if let urlPath = customObject?["a"]?["photo"] as? String {
            }
        }
        
        if(userInfoExtracted.notifFrom == "chat") {
            showBadgeCount(increase: true)
        }
        
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    func extractUserInfo(userInfo: [AnyHashable : Any]) -> (title: String, body: String, notifFrom: String) {
        
        let customObject = userInfo["custom"] as? [String: AnyObject]
        
        let object = customObject?["a"] as? [String: Any]
        let notifFrom = object?["notif_from"] as? String ?? ""
        
        var info = (title: "", body: "", notifFrom: "")
        guard let aps = userInfo["aps"] as? [String: Any] else { return info }
        guard let alert = aps["alert"] as? [String: Any] else { return info }
        
        let title = alert["title"] as? String ?? ""
        let body = alert["body"] as? String ?? ""
        info = (title: title, body: body, notifFrom: notifFrom)
        return info
    }
    
    func showBadgeCount(increase: Bool = false) {
        var count = KKCache.common.readInteger(key: .unreadNotificationCount(getIdUser())) ?? 0 //Get current count
        if increase {
            count += 1 //Plus one
            KKCache.common.save(integer: count, key: .unreadNotificationCount(getIdUser())) // Save the plus one
        }
        
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func updateOnce(JIRA_TICKET: String) {
        
        if !UserDefaults.standard.bool(forKey: JIRA_TICKET) {
            print("***** updateOnce() START", JIRA_TICKET)
            // DO ONCE THIS FUNCTION for JIRA_TICKET
            FeedSeenCache.instance.removeAllSeenFeed()
            //KKResourceLoader.instance.removeAllCache()
            
            DataCache.instance.cleanAll()
            UserDefaults.standard.set(true, forKey: JIRA_TICKET)
            print("***** updateOnce() FINISH", JIRA_TICKET)
        }
    }
    
    
    func updateKeychainStoreIfDiskTokenNotEmpty() {
        if tokenStore.retrieve() == nil {
            if let retreiveToken = retrieveCredentials() {
                updateLoginData(data: retreiveToken)
            }
        }
    }
    
    func refreshToken(completion: @escaping () -> Void) {
        if let keychainToken = tokenStore.retrieve(), !TokenCachePolicy.validate(expiredDate: keychainToken.expiresIn) {
            let request = TokenRequest(refresh_token: keychainToken.refreshToken)
            
            Task {
                do {
                    let newToken = try await tokenLoader.load(request: request)
                    if var retreiveToken = retrieveCredentials() {
                        retreiveToken.token = newToken.accessToken
                        retreiveToken.accessToken = newToken.accessToken
                        retreiveToken.refreshToken = newToken.refreshToken
                        retreiveToken.loginResponseRefreshToken = newToken.refreshToken
                        updateLoginData(data: retreiveToken)
                    }
                } catch {
                    NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
                }
                
                completion()
            }
        } else {
            completion()
        }
    }
    
    @objc private func didFailToRefreshToken(_ sender: Notification) {
        
        DispatchQueue.main.async {
            guard let topController = UIApplication.shared.keyWindow?.topViewController, topController is UIAlertController == false else {
                print("DEBUG: alert still visible")
                return
            }
            
            removeToken()
            RefreshToken.shared.logoutClearCache()
            
            self.window?.rootViewController?.dismiss(animated: false, completion: {
                let alertController = UIAlertController(title: "Login Expired",
                                                        message: "Your login session has expired. Please relogin to continue using the app.",
                                                        preferredStyle: .alert)
                
                let loginAction = UIAlertAction(title: "Login", style: .default, handler: { [weak self] (_) in
                    guard let self = self else { return }
                    self.clearNotifsNav()
                    let rootViewController = SplashScreenViewController().configure()
                    rootViewController.configureNotification()
                    self.window?.switchRootViewController(rootViewController, animated: false)
                })
                
                alertController.addAction(loginAction)
                
                if self.window?.rootViewController?.presentedViewController == nil {
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
}

// MARK: Keychain Store
private extension AppDelegate {
    func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
    
    func makeKeychainBlockedUserStore() -> BlockedUserStore {
        return KeychainBlockedUserStore()
    }
}

extension AppDelegate {
    @objc func showKeyboardAuto( noti:NSNotification ) {
        let isShowDone = noti.object as! String == "yes"  
        IQKeyboardManager.shared.enableAutoToolbar =  isShowDone
    }
    
    func dealWithkeyboard(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(showKeyboardAuto),
            name:.pushNotifForkeyboard, object: nil
        )
    }
    
    var hasNavigationController: Bool {
        return window?.topNavigationController != nil
    }
    
    func pushOnce(_ destinationViewController: UIViewController, animated: Bool = true) {
        guard let top = window?.topViewController, type(of: top) != type(of: destinationViewController) else {
            return
        }
        
        self.push(destinationViewController, animated: animated)
    }
    
    func push(_ destinationViewController: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            self.window?.topNavigationController?.pushViewController(
                destinationViewController,
                animated: animated
            )
        }
    }
    
    func presentOnce(_ destinationViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = window?.topViewController, type(of: top) != type(of: destinationViewController) else {
            return
        }
        DispatchQueue.main.async {
            self.window?.topViewController?.present(
                destinationViewController,
                animated: animated,
                completion: completion
            )
        }
    }
    
    func presentWithSlideAnimation(_ destinationViewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let top = window?.topViewController else { return }
        
        let interaction = InteractionConfiguration(
            presentingViewController: top,
            completionThreshold: 0.5,
            dragMode: .edge
        )
        let cover = CoverPresentation(
            directionShow: .right,
            directionDismiss: .right,
            size: PresentationSize(height: .fullscreen),
            alignment: PresentationAlignment(vertical: .bottom, horizontal: .center),
            interactionConfiguration: interaction
        )
        let animator = Animator(presentation: cover)
        animator.prepare(presentedViewController: destinationViewController)
        destinationViewController.presentationAnimator = animator
        
        presentOnce(destinationViewController, completion: completion)
    }
    
    func presentWithCoverAnimation(
        configuration: PresentationUIConfiguration = PresentationUIConfiguration(),
        size: PresentationSize = PresentationSize(),
        _ destinationViewController: UIViewController
    ) {
        guard let top = window?.topViewController else { return }
        
        let interaction = InteractionConfiguration(
            presentingViewController: top,
            completionThreshold: 0.5,
            dragMode: .canvas
        )

        let cover = CoverPresentation(
            directionShow: .bottom,
            directionDismiss: .bottom,
            uiConfiguration: configuration,
            size: size,
            alignment: PresentationAlignment(vertical: .bottom, horizontal: .center),
            interactionConfiguration: interaction
        )
        let animator = Animator(presentation: cover)
        animator.prepare(presentedViewController: destinationViewController)
        destinationViewController.presentationAnimator = animator
        
        presentOnce(destinationViewController)
    }
    
    func pushOnceAndPopLast(_ destinationViewController: UIViewController, animated: Bool = true) {
        guard let top = window?.topViewController, type(of: top) != type(of: destinationViewController) else {
            return pushThenPopLast()
        }
        
        func pushThenPopLast() {
            pushViewControllerWithPresentFallback(destinationViewController, animated: animated)
            popViewControllerBeforeLast()
        }
        
        window?.topNavigationController?.pushViewController(destinationViewController, animated: animated)
    }
    
    func pushViewControllerWithPresentFallback(_ destinationViewController: UIViewController, animated: Bool = true) {
        if hasNavigationController {
            window?.topNavigationController?.pushViewController(destinationViewController, animated: animated)
        } else {
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .fullScreen
            window?.topViewController?.present(navigationController, animated: animated)
        }
    }
    
    func dismissControllerWithPopFallback(animated: Bool = true, completion: (() -> Void)? = nil) {
        if hasNavigationController {
            if window?.topNavigationController?.presentingViewController != nil {
                window?.topNavigationController?.dismiss(animated: animated, completion: completion)
            } else {
                window?.topNavigationController?.popViewController(animated: animated)
                completion?()
            }
        } else {
            window?.topViewController?.dismiss(animated: animated, completion: completion)
        }
    }
    
    func dismiss(until topViewController: UIViewController.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = window?.topViewController, type(of: top) != topViewController else {
            completion?()
            return
        }
        
        // TODO: Need to be investigated
        guard let presenting = top.presentingViewController, type(of: presenting) != SplashScreenViewController.self else {
            completion?()
            return
        }
        
        dismissControllerWithPopFallback(animated: animated) { [weak self] in
            self?.dismiss(until: topViewController)
        }
    }
    
    func popViewControllerBeforeLast() {
        if let navigationController = window?.topNavigationController {
            
            let viewControllers = navigationController.viewControllers
            
            guard let last = viewControllers.last, let lastIndex = viewControllers.firstIndex(of: last) else {
                return
            }
            
            let indexToRemove = lastIndex - 1
            
            if indexToRemove < viewControllers.count {
                var viewControllers = navigationController.viewControllers
                viewControllers.remove(at: indexToRemove)
                navigationController.viewControllers = viewControllers
            }
        }
    }
}

// MARK: UIWindow
var rootViewControllerKey: UInt8 = 0

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
 
    func switchRootViewController(_ viewController: UIViewController,  animated: Bool = true, duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .transitionFlipFromBottom, completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            return
        }
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
    
    func switchRootWithPushTo(viewController: UIViewController, withAnimation animation: CATransitionSubtype = .fromRight) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = animation
        transition.isRemovedOnCompletion = true
        
        self.layer.add(transition, forKey: kCATransition)
        self.rootViewController = viewController
    }
}
