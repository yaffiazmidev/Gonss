//
//  EditPasswordInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/03/23.
//

import UIKit

protocol IEditPasswordInteractor: AnyObject {
    var oldPassword: String { get set }
    var newPassword: String { get set }
    
    func updatePassword()
}

class EditPasswordInteractor: IEditPasswordInteractor {
    
    private let presenter: IEditPasswordPresenter
    private let network: DataTransferService
    
    var oldPassword: String = ""
    var newPassword: String = ""
    
    init(presenter: IEditPasswordPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func updatePassword() {
        let endpoint = Endpoint<RemoteUpdatePassword?>(
            path: "account/\(getIdUser())/setting/password",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "oldPassword" : oldPassword,
                "password" : newPassword,
                "deviceId" : getDeviceId()
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentUpdatePassword(with: result)
        }
    }
}
