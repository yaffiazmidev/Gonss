//
//  ConfirmPasswordInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/02/23.
//

import UIKit

protocol IConfirmPasswordInteractor: AnyObject {
    func verifyPassword(_ value: String)
}

class ConfirmPasswordInteractor: IConfirmPasswordInteractor {
    
    private let presenter: IConfirmPasswordPresenter
    private let network: DataTransferService
    
    init(presenter: IConfirmPasswordPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func verifyPassword(_ value: String) {
        let endpoint: Endpoint<RemoteDefaultBool?> = Endpoint(
            path: "balance/verify",
            method: .post,
            headerParamaters: ["Authorization": "Bearer \(getToken() ?? "")", "Content-Type": "application/json"],
            queryParameters: ["password": value]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentVerifyPassword(with: result)
        }
    }
}
