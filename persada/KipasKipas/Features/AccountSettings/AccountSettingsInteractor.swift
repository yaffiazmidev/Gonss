//
//  AccountSettingsInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/03/23.
//

import UIKit

protocol IAccountSettingsInteractor: AnyObject {
    func checkUsername()
    func checkPhoneNumber()
    func checkProfile()
}

class AccountSettingsInteractor: IAccountSettingsInteractor {
    
    private let presenter: IAccountSettingsPresenter
    private let network: DataTransferService
    
    init(presenter: IAccountSettingsPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func checkUsername() {
        let endpoint = Endpoint<DefaultEntity?>(
            path: "account/setting/username/check",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCheckUsername(with: result)
        }
    }
    
    func checkPhoneNumber() {
        let endpoint = Endpoint<DefaultEntity?>(
            path: "account/setting/mobile/check",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCheckPhoneNumber(with: result)
        }
    }
    
    func checkProfile() {

        let endpoint = Endpoint<ProfileResult?>(
            path: "profile/\(getIdUser())",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCheckReferalCode(with: result)
        }
    }

}
