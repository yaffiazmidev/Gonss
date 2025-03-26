import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

public protocol ICoinPurchaseDetailRouter {
	// do someting...
}

public class CoinPurchaseDetailRouter: ICoinPurchaseDetailRouter {
    weak var controller: CoinPurchaseDetailViewController?
    
    public init(controller: CoinPurchaseDetailViewController?) {
        self.controller = controller
    }
}

extension CoinPurchaseDetailRouter {
    public static func create(
        baseUrl: String,
        authToken: String?,
        purchaseStatus: CoinPurchaseStatus,
        purchaseType: CoinActivityType,
        id: String,
        historyDetail: RemoteCurrencyHistoryDetailData?,
        isPresent: Bool = false
    ) -> CoinPurchaseDetailViewController {
        let controller = CoinPurchaseDetailViewController(
            isPresent: isPresent,
            purchaseStatus: purchaseStatus,
            purchaseType: purchaseType,
            id: id,
            historyDetail: historyDetail
        )
        let router = CoinPurchaseDetailRouter(controller: controller)
        let presenter = CoinPurchaseDetailPresenter(controller: controller)
        let network = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = CoinPurchaseDetailInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
