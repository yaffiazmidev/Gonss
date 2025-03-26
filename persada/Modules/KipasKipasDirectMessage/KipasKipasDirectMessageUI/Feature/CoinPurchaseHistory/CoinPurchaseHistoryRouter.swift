import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol ICoinPurchaseHistoryRouter {
    func navigateToCoinPurchaseDetail(
        purchaseStatus: CoinPurchaseStatus,
        purchaseType: CoinActivityType,
        id: String
    )
}

class CoinPurchaseHistoryRouter: ICoinPurchaseHistoryRouter {
    weak var controller: CoinPurchaseHistoryViewController?
    private let baseUrl: String
    private let authToken: String
    
    init(controller: CoinPurchaseHistoryViewController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
    
    func navigateToCoinPurchaseDetail(
        purchaseStatus: CoinPurchaseStatus,
        purchaseType: CoinActivityType,
        id: String
    ) {
        let vc = CoinPurchaseDetailRouter.create(
            baseUrl: baseUrl,
            authToken: authToken,
            purchaseStatus: purchaseStatus, 
            purchaseType: purchaseType,
            id: id,
            historyDetail: nil
        )
        controller?.push(vc)
    }
}

extension CoinPurchaseHistoryRouter {
    static func create(baseUrl: String, authToken: String) -> CoinPurchaseHistoryViewController {
        let controller = CoinPurchaseHistoryViewController()
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let router = CoinPurchaseHistoryRouter(controller: controller, baseUrl: baseUrl, authToken: authToken)
        let presenter = CoinPurchaseHistoryPresenter(controller: controller)
        let interactor = CoinPurchaseHistoryInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
