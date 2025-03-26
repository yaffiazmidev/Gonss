//
//  LocalRankDonationRouter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ILocalRankDonationRouter {
}

class LocalRankDonationRouter: ILocalRankDonationRouter {
    weak var controller: LocalRankDonationController?
    
    init(controller: LocalRankDonationController?) {
        self.controller = controller
    }
}

extension LocalRankDonationRouter {
    static func configure(id: String) -> LocalRankDonationController {
        let controller = LocalRankDonationController(id: id)
        let router = LocalRankDonationRouter(controller: controller)
        let presenter = LocalRankDonationPresenter(controller: controller)
        let network = DIContainer.shared.defaultAPIDataTransferService
        let authNetwork = DIContainer.shared.apiDataTransferService
        let interactor = LocalRankDonationInteractor(presenter: presenter, network: AUTH.isLogin() ? authNetwork : network)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
