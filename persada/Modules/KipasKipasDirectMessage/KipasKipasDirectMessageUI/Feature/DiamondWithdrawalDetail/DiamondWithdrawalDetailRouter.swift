import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

public protocol IDiamondWithdrawalDetailRouter {
	// do someting...
}

public class DiamondWithdrawalDetailRouter: IDiamondWithdrawalDetailRouter {
    weak var controller: DiamondWithdrawalDetailViewController?
    
    public init(controller: DiamondWithdrawalDetailViewController?) {
        self.controller = controller
    }
}

extension DiamondWithdrawalDetailRouter {
    public static func create(
        network: DataTransferService? = nil,
        baseUrl: String? = nil,
        authToken: String? = nil,
        status: DiamondPurchaseStatus,
        type: DiamondActivityType,
        id: String,
        historyDetail: RemoteCurrencyHistoryDetailData?
    ) -> DiamondWithdrawalDetailViewController {
        let controller = DiamondWithdrawalDetailViewController(
            withdrawalStatus: status,
            type: type,
            id: id,
            historyDetail: historyDetail
        )
        let router = DiamondWithdrawalDetailRouter(controller: controller)
        let presenter = DiamondWithdrawalDetailPresenter(controller: controller)
        
        #warning("[BEKA] Put back/remember to change it")
        let interactor = DiamondWithdrawalDetailInteractor(presenter: presenter, network: network ?? DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl ?? "", authToken: authToken ?? ""))
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
