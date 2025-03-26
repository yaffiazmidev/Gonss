//
//  InputUserInfoViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit

class InputUserInfoViewModel {
    
    // MARK:- Public Property

    private let networkModel: AuthNetworkModel?
    
    var changeHandler: ((InputUserInfoChangeViewModel) -> Void)?
    var name: String?
    var phone: String?
    var password: String?
    var imageUrl: String?
    var username: String?
    var otpCode: String?
    
    // MARK:- Public Mehtod
    
    init(networkModel: AuthNetworkModel ) {
        self.networkModel = networkModel
    }
    
    func inputUserInfo() {
        networkModel?.inputUserInfo(.inputUser(firstName: name ?? "", phone: phone ?? "", password: password ?? "", photo: imageUrl ?? "", username: username ?? "", otpCode: otpCode ?? ""), { [weak self] (result) in
            guard let self = self else {
                return
            }

            switch result {
            case .failure(let error):
                self.emit(.didEncounterError(error))
            case .success(let response):
                updateToken(data: response)
                self.emit(.didUpdateInputUser)
            }
        })
    }
    
    func emit(_ change: InputUserInfoChangeViewModel) {
        self.changeHandler?(change)
    }
}

enum InputUserInfoChangeViewModel {
    case didUpdateInputUser
    case didEncounterError(ErrorMessage?)
}
