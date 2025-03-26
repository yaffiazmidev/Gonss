import KipasKipasDonateStuffiOS
import UIKit
import KipasKipasNetworking
import KipasKipasDonateStuff
import KipasKipasShared
import Combine
import KipasKipasImage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private(set) lazy var toolsBaseUrl: URL = {
        let stringUrl = Bundle.main.infoDictionary!  ["API_TOOLS_BASE_URL"] as! String
        return URL(string: stringUrl)!
    }()
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.KipasKipas.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private(set) lazy var tokenStore: TokenStore = {
        return KeychainTokenStore()
    }()
    
    private(set) lazy var httpClient: HTTPClient = {
        return makeHTTPClient(baseURL: toolsBaseUrl).httpClient
    }()
    
    private(set) lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: toolsBaseUrl).authHTTPClient
    }()
    
    private(set) lazy var loader: DonateStuffLoader = {
        let loader = RemoteDonateStuffLoader(baseURL: toolsBaseUrl, client: httpClient)
        return loader
    }()
    
    private(set) lazy var listController: ListDonateStuffController = {
        let controller = ListDonateStuffController()
        controller.loader = loader
        return controller
    }()
    
    private lazy var navigationController = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        UIFont.loadCustomFonts
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        navigationController.setViewControllers([
            DummyVC(),
        ], animated: false)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
        
       // navigationController.pushViewController(makeDonationItemListViewController(), animated: true)
        // navigationController.pushViewController(makeDonationItemDetailViewController(), animated: true)
        navigationController.pushViewController(makeDonationItemPaymentViewController(), animated: true)

    }

    private lazy var dummy = {
        return PassthroughSubject<DonationItemData, AnyError>()
    }()
    
    private lazy var detailDummy = {
        return PassthroughSubject<DonationItemDetailData, AnyError>()
    }()
    
    private lazy var paymentDummy = {
        return PassthroughSubject<DonationItemPaymentData, AnyError>()
    }()
    
    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

extension SceneDelegate {
    
    final class DummyVC: UIViewController, NavigationAppearance {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupNavigationBar(backIndicator: .iconChevronLeft)
        }
    }
    
    private func makeDonationItemListViewController() -> UIViewController {
        let destination = DonationItemListUIComposer.composeWith(
            type: .donor,
            loader: makeDonationItemListLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader), 
            parameter: .init(postDonationId: ""),
            actions: .init(selection: { _ in })
        )
        return destination
    }
    
    private func makeDonationItemDetailViewController() -> UIViewController {
        let actions = DonationItemDetailUIComposer.Actions(didTapDonateButton: pushToDonationItemCheckoutViewController)
        let controller = DonationItemDetailUIComposer.composeWith(
            loader: makeDonationItemDetailLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader), 
            parameter: .init(id: ""),
            actions: actions
        )
        controller.configureDismissablePresentation(backIcon: .iconArrowLeftCircleBlack)
        return controller
    }
    
    private func makeDonationItemPaymentViewController() -> UIViewController {
        let controller = DonationItemPaymentUIComposer.composeWith(
            loader: makeDonationItemPaymentLoader,
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            dummyLoad: { [weak self] in
                self?.paymentDummy.send(.init(code: "", message: "", data: .mock))
            }
        )
        return controller
    }
    
    private func makeDonationItemPaymentLoader(_ orderId: String) -> API<DonationItemPaymentData, AnyError> {
        return paymentDummy
            .delay(for: .seconds(1), scheduler: scheduler)
            .eraseToAnyPublisher()
    }
    
    func pushToDonationItemCheckoutViewController(
        viewModel: DonationItemDetailViewModel,
        quantity: Int
    ) {
        let destination = DonationItemCheckoutUIComposer.composeWith(
            imageLoader: ImageResourceLoader(publisher: makeImageLoader),
            parameter: .init(
                viewModel: viewModel,
                quantity: quantity
            )
        )
        
       navigationController.pushViewController(destination, animated: true)
    }
    
    private func makeDonationItemListLoader(_ param: String) -> API<DonationItemData, AnyError> {
//        return httpClient.getPublisher(
//            request: .url(toolsBaseUrl)
//                .path("/donatur/donations/402880e78e75a9a2018e78d7fa94003a/items")
//                .method(.GET)
//                .build()
//        )
//        .tryMap(Mapper<DonationItemData>.map)
//        .delayOutput(for: 1)
//        .mapError({
//            error in
//            let mappedError = MapperError.map(error)
//            return AnyError(
//                code: mappedError.code,
//                message: mappedError.message,
//                data: mappedError.data
//            )
//        })
//        .subscribe(on: scheduler)
//        .eraseToAnyPublisher()
        return dummy
            .delay(for: .seconds(1), scheduler: DispatchQueue.global(qos: .background))
            .eraseToAnyPublisher()
    }
    
    private func makeDonationItemDetailLoader(_ param: String) -> API<DonationItemDetailData, AnyError> {
        return detailDummy
            .debounce(for: 1, scheduler: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeImageLoader(url: URL) -> API<[String: Data], AnyError> {
        return RemoteImageLoader.shared
            .getPublisher(url: url)
            .retry(3)
            .tryMap({ data in
                return [url.absoluteString: data]
            })
            .mapError({ _ in return AnyError(code: "no-image") })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
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
