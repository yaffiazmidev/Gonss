//
//  AddGopayAccountRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/04/23.
//

import Foundation

protocol IAddGopayAccountRouter {
	// do someting...
}

class AddGopayAccountRouter: IAddGopayAccountRouter {
    weak var controller: AddGopayAccountViewController?
    
    init(controller: AddGopayAccountViewController?) {
        self.controller = controller
    }
}

extension AddGopayAccountRouter {
    static func configure(controller: AddGopayAccountViewController) {
        let router = AddGopayAccountRouter(controller: controller)
        let presenter = AddGopayAccountPresenter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let interactor = AddGopayAccountInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
    }
}
