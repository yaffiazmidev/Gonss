//
//  WithdrawDonationBalanceInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/02/23.
//

import UIKit

protocol IWithdrawDonationBalanceInteractor: AnyObject {
    func withdraw(bankAccountId: String, nominal: Double, postDonationId: String, isGopay: Bool)
}

class WithdrawDonationBalanceInteractor: IWithdrawDonationBalanceInteractor {
    
    private let presenter: IWithdrawDonationBalancePresenter
    private let network: DataTransferService
    
    init(presenter: IWithdrawDonationBalancePresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func withdraw(bankAccountId: String, nominal: Double, postDonationId: String, isGopay: Bool) {
        let path = "balance/donations/withdraw\(isGopay ? "/payout" : "")"
        let headerParamaters = ["Authorization": "Bearer \(getToken() ?? "")", "Content-Type": "application/json"]
        let bodyParamaters: [String: Any] = ["bankAccountId": bankAccountId, "nominal": nominal, "postDonationId": postDonationId]
        
        if isGopay {
            let endpoint: Endpoint<RemoteDonationWithdrawGopay?> = Endpoint(
                path: path, method: .post,
                headerParamaters: headerParamaters,
                bodyParamaters: bodyParamaters
            )
            
            network.request(with: endpoint) { [weak self] result in
                guard let self = self else { return }
                self.presenter.presentWithdrawalGopay(with: result)
            }
        } else {
            let endpoint: Endpoint<RemoteDonationWithdrawBank?> = Endpoint(
                path: path, method: .post,
                headerParamaters: headerParamaters,
                bodyParamaters: bodyParamaters
            )
            
            network.request(with: endpoint) { [weak self] result in
                guard let self = self else { return }
                self.presenter.presentWithdrawalBank(with: result)
            }
        }
    }
}
