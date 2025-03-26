import UIKit
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseInteractor: AnyObject {
    func requestBalanceDetsil()
    func requestUUID()
    func requestCoinProduct()
    func requestCoinInApp(products ids: [String])
    func requestCoinPurchaseTransaction(product: InAppPurchaseProduct, userId: String)
    func requestCoinPurchaseValidate(transaction id: String)
    //    func requestCurrencyInfo()
}

class CoinPurchaseInteractor: ICoinPurchaseInteractor {
    
    private let presenter: ICoinPurchasePresenter
    private let network: DataTransferService
    private let inAppLoader: InAppPurchaseProductLoader
    private let inAppPurchaser: InAppPurchaseProductPurchaser
    private let coinInAppValidator: CoinInAppPurchaseValidator
    private let storeId = "e7b0c0a4-8c1f-4db8-a403-4eca7c6fdb2c"
    
    init(presenter: ICoinPurchasePresenter, network: DataTransferService, inAppLoader: InAppPurchaseProductLoader, inAppPurchaser: InAppPurchaseProductPurchaser, coinInAppValidator: CoinInAppPurchaseValidator) {
        self.presenter = presenter
        self.network = network
        self.inAppLoader = inAppLoader
        self.inAppPurchaser = inAppPurchaser
        self.coinInAppValidator = coinInAppValidator
    }
    
    func requestBalanceDetsil() {
        let endpoint: Endpoint<RemoteBalanceCurrency?> = Endpoint(
            path: "balance/currency/info",
            method: .get
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("Error: Failed to get my coin - \(error.message ?? "")")
//                self.presenter.presentBalanceDetail(with: result)
            case .success(let response):
                self.presenter.presentBalanceDetail(with: result)
            }
        }
    }
    
    func requestCoinProduct() {
        let endpoint: Endpoint<RemoteCoinPurchaseProduct?> = Endpoint(path: "coin/", method: .get, queryParameters: ["storeId": storeId])
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentCoinProduct(with: result)
        }
    }
    
    func requestCoinInApp(products ids: [String]) {
        let request = InAppPurchaseProductLoaderRequest(identifiers: ids)
        
        inAppLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentCoinInApp(with: result)
        }
    }
    
    func requestCoinPurchaseTransaction(product: InAppPurchaseProduct, userId: String) {
        guard !userId.isEmpty else {
            presenter.presentCoinPurchaseTransaction(with: .failure(NSError(domain: "User Data not valid", code: 0)))
            return
        }
        
        let request = InAppPurchaseProductPurchaserRequest(product: product, applicationUsername: userId)
        inAppPurchaser.purchase(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentCoinPurchaseTransaction(with: result)
        }
    }
    
    func requestCoinPurchaseValidate(transaction id: String) {
        let request = CoinInAppPurchaseValidatorRequest(storeId: storeId, transactionId: id)
        
        coinInAppValidator.validate(request: request) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCoinPurchaseValidate(with: result, transactionId: id)
        }
    }
    
    func requestUUID() {
        inAppLoader.getUUID { [weak self] uuid in
            self?.presenter.presentUUID(with: uuid)
        }
    }
//    func requestCurrencyInfo() {
//        
//        let endpoint: Endpoint<RemoteCurrencyInfo?> = Endpoint(path: "balance/currency/info", method: .get)
//        
//        network.request(with: endpoint) { [weak self] result in
//            guard let self = self else { return }
//            
//            self.presenter.presentCurrencyInfo(with: result)
//        }
//    }
}
