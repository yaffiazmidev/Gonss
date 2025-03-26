//
//  EmailValidatorService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class EmailValidatorService: EmailValidatorControllerDelegate {
    
    private let checker: EmailValidator
    var presenter: EmailValidatorPresenter?
    
    init(checker: EmailValidator) {
        self.checker = checker
    }
    
    func didValidateEmail(request: EmailValidatorRequest) {
        presenter?.didStartLoadingGetEmailValidator()
        checker.check(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetEmailValidator(with: item)
            case let .failure(error):
                if let error = error as? KKNetworkError {
                    switch error {
                    case .emailAlreadyExists:
                        self.presenter?.didEmailValidatorAlreadyExists(with: error)
                    default:
                        self.presenter?.didFinishLoadingGetEmailValidator(with: error)
                    }
                } else {
                    self.presenter?.didFinishLoadingGetEmailValidator(with: error)
                }
            }
        }
    }
}

