//
//  DeleteAccountRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 26/01/22.
//

import Foundation

protocol DeleteAccountRouterRoutingLogic {
}

class DeleteAccountRouter: DeleteAccountRouterRoutingLogic {
    weak var controller: DeleteAccountViewController?
    
    init(_ controller: DeleteAccountViewController?) {
        self.controller = controller
    }
}

extension DeleteAccountRouter {
    static func create(parameters: [String: Any] = [:]) -> DeleteAccountViewController {
        let controller = DeleteAccountViewController()
        let router = DeleteAccountRouter(controller)
        let presenter = DeleteAccountPresenter(controller)
        let interactor = DeleteAccountInteractor(presenter: presenter, 
                                                 profileNetwork: ProfileNetworkModel(),
                                                 authUsecase: Injection.init().provideAuthUseCase())
        interactor.parameters = parameters
        controller.interactor = interactor
        controller.router = router
        return controller
    }
}
