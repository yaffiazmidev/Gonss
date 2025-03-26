import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasRegisteriOS
import KipasKipasCamera

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private(set) lazy var baseURL: URL = {
        let baseURL = Bundle.main.infoDictionary! ["API_BASE_URL"] as! String
        return URL(string: baseURL)!
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
    
    private(set) lazy var mediaUploader: MediaUploader = {
        return MediaUploadManager()
    }()

    private(set) lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KipasKipasRegisterApp.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var navigationController = UINavigationController()
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        UIFont.loadCustomFonts
        
        let window = UIWindow(windowScene: windowScene)
        
        navigationController.setViewControllers([makeBirthdayPickerViewController()], animated: true)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
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
