//
//  EditPhoneNumberInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/03/23.
//

import UIKit

protocol IEditPhoneNumberInteractor: AnyObject {
    var phoneNumber: String { get set }
    
    func checkPhoneNumber()
}

class EditPhoneNumberInteractor: IEditPhoneNumberInteractor {
    
    private let presenter: IEditPhoneNumberPresenter
    private let network: DataTransferService
    var phoneNumber: String = ""
    
    init(presenter: IEditPhoneNumberPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func checkPhoneNumber() {
        let endpoint = Endpoint<VerifyPhoneNumberEntity?>(
            path: "auth/otp/validation/phone-number",
            method: .post,
            headerParamaters: ["Content-Type":"application/json"],
            bodyParamaters: [ "type": "REGISTER", "phoneNumber": phoneNumber ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentCheckPhoneNumber(with: result)
        }
    }
}
