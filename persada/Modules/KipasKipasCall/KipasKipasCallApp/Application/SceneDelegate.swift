//
//  SceneDelegate.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import Combine
import KipasKipasLogin
import KipasKipasLoginiOS
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasShared
import KipasKipasCall

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private(set) lazy var defaults = UserDefaults.standard
    
    var cancellables: Set<AnyCancellable> = []
    
    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.mobile.KipasKipasCallApp.queue",
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
    
    private lazy var callVideoController: CallViewController = {
        let controller = CallViewController()
        controller.delegate = self
        controller.profileDelegate = self
        return controller
    }()
    
    private lazy var navigationController = UINavigationController(rootViewController: callVideoController)
    
    private(set) lazy var callAuthenticator: CallAuthenticator = {
        let auth = TUICallAuthenticator()
        return MainQueueDispatchDecorator(decoratee: auth)
    }()
    
    private(set) lazy var callLoader: CallLoader = {
        let loader = TUICallLoader()
        let decorator = CallLoaderAuthDecorator(decoratee: loader, auth: callAuthenticator)
        return MainQueueDispatchDecorator(decoratee: decorator)
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UIFont.loadCustomFonts
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        configureRootViewController(in: window)
        window.makeKeyAndVisible()
        
        self.window = window
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
        
        window.rootViewController = navigationController
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

extension SceneDelegate: CallViewControllerDelegate {
    func didUserLoginData(data: CallProfile) {
        let userSig = TencentUserSig.genTestUserSig(data.id)
        let request = TUICallLoginAuthenticatorRequest(fullName: data.name, pictureUrl: data.photo ?? "", userId: data.id, sdkAppId: UInt32(SDKAPPID), userSig: userSig)
        callAuthenticator.login(with: request, completion: didTUILogin(with:))
    }
    
    func didCall(target: CallProfile, type: CallType) {
        let store = loggedInUserStore.retrieve()
        let userId = store?.accountId ?? ""
        let roomId = [target.id, userId].sorted().joined(separator: "_")
        let request = CallLoaderRequest(roomId: roomId, userId: target.id, type: type)
        callLoader.call(with: request, completion: didTUICall(with:))
    }
    
    func didLogout() {
        callAuthenticator.logout(completion: didTUILogout(with:))
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
