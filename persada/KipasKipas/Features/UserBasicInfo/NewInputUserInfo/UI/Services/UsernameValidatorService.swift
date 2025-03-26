//
//  UsernameValidatorService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class UsernameValidatorService: UsernameValidatorControllerDelegate {
    
    private let checker: UsernameValidator
    var presenter: UsernameValidatorPresenter?
    
    init(checker: UsernameValidator) {
        self.checker = checker
    }
    
    func didValidateUsername(request: UsernameValidatorRequest) {
        presenter?.didStartLoadingGetUsernameValidator()
        checker.check(request: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(userItem):
                self.presenter?.didFinishLoadingGetUsernameValidator(with: userItem)
            case let .failure(error):
                if let error = error as? KKNetworkError {
                    switch error {
                    case .usernameAlreadyExists:
                        self.presenter?.didUsernameValidatorAlreadyExists(with: error)
                    default:
                        self.presenter?.didFinishLoadingGetUsernameValidator(with: error)
                    }
                } else {
                    self.presenter?.didFinishLoadingGetUsernameValidator(with: error)
                }
            }
        }
    }
}



