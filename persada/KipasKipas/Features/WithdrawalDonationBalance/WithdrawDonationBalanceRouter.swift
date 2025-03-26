//
//  WithdrawDonationBalanceRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/02/23.
//

import Foundation

protocol IWithdrawDonationBalanceRouter {
	// do someting...
}

class WithdrawDonationBalanceRouter: IWithdrawDonationBalanceRouter {
    weak var controller: WithdrawDonationBalanceViewController?
    
    init(controller: WithdrawDonationBalanceViewController?) {
        self.controller = controller
    }
}

extension WithdrawDonationBalanceRouter {
    static func configure(amountAvailable: Double, campaignId: String) -> WithdrawDonationBalanceViewController {
        let controller = WithdrawDonationBalanceViewController(
            amountAvailable: amountAvailable,
            postDonationId: campaignId
        )
        let router = WithdrawDonationBalanceRouter(controller: controller)
        let presenter = WithdrawDonationBalancePresenter(controller: controller)
        let network = DIContainer.shared.apiDataTransferService
        let interactor = WithdrawDonationBalanceInteractor(presenter: presenter, network: network)
        controller.router = router
        controller.interactor = interactor
        
        return controller
    }
}
