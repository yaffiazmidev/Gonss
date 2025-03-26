import UIKit
import Foundation
import KipasKipasDirectMessage
#warning("[BEKA] Remove this")
import KipasKipasNetworking

protocol IBankAccountRouter {
    
}

class BankAccountRouter: IBankAccountRouter {
    weak var controller: BankAccountController?
    private let baseUrl: String
    private let authToken: String
    
    init(controller: BankAccountController?, baseUrl: String, authToken: String) {
        self.controller = controller
        self.baseUrl = baseUrl
        self.authToken = authToken
    }
}

extension BankAccountRouter {
    static func create(baseUrl: String, authToken: String, selectedBank: ((BankAccountItem) -> Void)?) -> BankAccountController {
        let controller = BankAccountController()
        let router = BankAccountRouter(controller: controller, baseUrl: baseUrl, authToken: authToken)
        let presenter = BankAccountPresenter(controller: controller)
        let network: DataTransferService = DIContainer.shared.apiAUTHDTS(baseUrl: baseUrl, authToken: authToken)
        let interactor = BankAccountInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        controller.selectedBank = selectedBank
        
        return controller
    }
}
