//
//  EditUsernameInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/03/23.
//

import UIKit

protocol IEditUsernameInteractor: AnyObject {
    var username: String { get set }
    
    func updateUsername()
}

class EditUsernameInteractor: IEditUsernameInteractor {
    
    private let presenter: IEditUsernamePresenter
    private let network: DataTransferService
    var username: String = ""
    
    init(presenter: IEditUsernamePresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func updateUsername() {
        let endpoint = Endpoint<RemoteUpdateUsername?>(
            path: "account/\(getIdUser())/setting/username",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "username" : username,
                "deviceId" : getDeviceId()
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentUpdateUsername(with: result)
        }
    }
}
