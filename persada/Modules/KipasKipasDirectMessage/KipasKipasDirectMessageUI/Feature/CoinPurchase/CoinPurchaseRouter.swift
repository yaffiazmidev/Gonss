import Foundation
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
import UIKit
import KipasKipasNetworking
import KipasKipasShared

protocol ICoinPurchaseRouter {
	func navigateToCoinPurchaseHistory()
    func presentTnCWebView()
    func presentCoinPurchaseDetail(with data: CoinInAppPurchaseValidateData)
}

public class CoinPurchaseRouter: ICoinPurchaseRouter {
    weak var controller: CoinPurchaseViewController?
    let baseUrl: String
    let authToken: String
    
    init(controller: CoinPurchaseViewController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
    
    func navigateToCoinPurchaseHistory() {
        let vc = CoinPurchaseHistoryRouter.create(baseUrl: baseUrl, authToken: authToken)
        controller?.push(vc)
    }
    
    func presentTnCWebView() {
        let tncURL = "https://kipaskipas.com/syarat-dan-ketentuan-kipaskipas/#1694507162312-fe639895-f17e"
        let vc = KKWebViewController(url: tncURL)
        vc.bindNavBar("", isPresent: true)
        let navigate = UINavigationController(rootViewController: vc)
        controller?.present(navigate, animated: true)
    }
    
    func presentCoinPurchaseDetail(with data: CoinInAppPurchaseValidateData) {
        let vc = CoinPurchaseDetailRouter.create(
            baseUrl: baseUrl,
            authToken: authToken,
            purchaseStatus: .complete,
            purchaseType: .topup,
            id: "",
            historyDetail: data.toCurrencyHistoryDetail()
        )
        controller?.push(vc)
    }
}

fileprivate extension CoinInAppPurchaseValidateData {
    func toCurrencyHistoryDetail() -> RemoteCurrencyHistoryDetailData? {
        return RemoteCurrencyHistoryDetailData(
            invoiceNumber: orderCoin.noInvoice,
            accountNumber: nil,
            storeName: orderCoin.store.storeName,
            totalAmount: orderCoin.detail.totalAmount,
            id: nil,
            conversionPerUnit: nil,
            bankFee: nil,
            recipient: nil,
            accountName: nil,
            createAt: orderCoin.createAt,
            qty: orderCoin.detail.coinAmount,
            currencyType: "COIN",
            bankName: nil,
            userName: nil
        )
    }
}

extension CoinPurchaseRouter {
    public static func create(baseUrl: String, authToken: String) -> CoinPurchaseViewController {
        let controller = CoinPurchaseViewController()
        let router = CoinPurchaseRouter(controller: controller, baseUrl: baseUrl, authToken: authToken)
        let presenter = CoinPurchasePresenter(controller: controller)
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let inAppLoader = StoreKitInAppPurchaseProductLoader(baseURL: URL(string: baseUrl)!, client: makeHTTPClient(baseUrl: baseUrl))
        let inAppPurchaser = StoreKitInAppPurchaseProductPurchaser()
        let coinInAppValidator = RemoteCoinInAppPurchaseValidator(url: URL(string: baseUrl)!, client: makeHTTPClient(baseUrl: baseUrl))
        let interactor = CoinPurchaseInteractor(presenter: presenter, network: network, inAppLoader: MainQueueDispatchDecorator(decoratee: inAppLoader), inAppPurchaser: inAppPurchaser, coinInAppValidator: coinInAppValidator)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
    
    private static func makeHTTPClient(baseUrl url: String) -> AuthenticatedHTTPClientDecorator {
        let baseURL = URL(string: url)!
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        
        let localTokenLoader = LocalTokenLoader(store: makeKeychainTokenStore())
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: localTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: makeKeychainTokenStore(), loader: tokenLoader)
        
        return authHTTPClient
    }
    
    private static func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
}

extension MainQueueDispatchDecorator: InAppPurchaseProductLoader where T == InAppPurchaseProductLoader {
    public func getUUID(completion: @escaping (String?) -> Void) {
        decoratee.getUUID { [weak self] uuid in
            self?.dispatch { completion(uuid) }
        }
    }
    
    public func load(request: InAppPurchaseProductLoaderRequest, completion: @escaping (InAppPurchaseProductLoader.Result) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
