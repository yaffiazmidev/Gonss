//
//  AddGopayAccountInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/04/23.
//

import UIKit

protocol IAddGopayAccountInteractor: AnyObject {
    var phoneNumber: String { get set }
    
    func checkGopayAccount()
}

class AddGopayAccountInteractor: IAddGopayAccountInteractor {
    
    private let presenter: IAddGopayAccountPresenter
    private let network: DataTransferService
    var phoneNumber: String = ""
    
    init(presenter: IAddGopayAccountPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func checkGopayAccount() {
        let endpoint: Endpoint<RemoteCheckGopayAccount?> = Endpoint(
            path: "bankaccounts/check-account",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["type": "gopay", "number": phoneNumber]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCheckGopayAccount(with: result)
        }
    }
}
