import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IDiamondWithdrawalHistoryRouter {
    func navigateToDiamondWithdrawalDetail(
        status: DiamondPurchaseStatus,
        type: DiamondActivityType,
        id: String
    )
}

class DiamondWithdrawalHistoryRouter: IDiamondWithdrawalHistoryRouter {
    weak var controller: DiamondWithdrawalHistoryViewController?
    private let network: DataTransferService
    
    init(controller: DiamondWithdrawalHistoryViewController? , network: DataTransferService) {
        self.controller = controller
        self.network = network
    }
    
    func navigateToDiamondWithdrawalDetail(
        status: DiamondPurchaseStatus,
        type: DiamondActivityType,
        id: String
    ) {
        let vc = DiamondWithdrawalDetailRouter.create(
            network: network,
            status: status,
            type: type,
            id: id,
            historyDetail: nil
        )
      
        vc.bindNavBar()
        controller?.push(vc)
    }
}

extension DiamondWithdrawalHistoryRouter {
    static func create(baseUrl: String, authToken: String) -> DiamondWithdrawalHistoryViewController {
        let controller = DiamondWithdrawalHistoryViewController()
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let router = DiamondWithdrawalHistoryRouter(controller: controller, network: network)
        let presenter = DiamondWithdrawalHistoryPresenter(controller: controller)
        let interactor = DiamondWithdrawalHistoryInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
