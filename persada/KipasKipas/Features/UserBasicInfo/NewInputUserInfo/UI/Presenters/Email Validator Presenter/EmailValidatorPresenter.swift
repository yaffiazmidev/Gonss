//
//  EmailValidatorPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class EmailValidatorPresenter {
    private let successView: EmailValidatorView?
    private let loadingView: EmailValidatorLoadingView?
    private let errorView: EmailValidatorLoadingErrorView?
    private let alreadyExistsView: EmailValidatorAlreadyExistsView?
    
    init(
        successView: EmailValidatorView,
        loadingView: EmailValidatorLoadingView,
        errorView: EmailValidatorLoadingErrorView,
        alreadyExistsView: EmailValidatorAlreadyExistsView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
            self.alreadyExistsView = alreadyExistsView
    }
    
    static var loadError: String {
        NSLocalizedString("EMAIL_VALIDATOR_GET_ERROR",
                          tableName: "InputUserWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    static var alreadyExists: String {
        NSLocalizedString("INPUT_USER_EMAIL_ALREADY_EXISTS",
                          tableName: "InputUserWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed email already exists from the server")
    }
    
    func didStartLoadingGetEmailValidator() {
        errorView?.display(.noError)
        alreadyExistsView?.display(.noError)
        loadingView?.display(EmailValidatorLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetEmailValidator(with item: EmailValidatorResponseItem) {
        successView?.display(EmailValidatorViewModel(item: item))
        loadingView?.display(EmailValidatorLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetEmailValidator(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(EmailValidatorLoadingViewModel(isLoading: false))
    }
    
    func didEmailValidatorAlreadyExists(with error: Error) {
        alreadyExistsView?.display(.error(message: Self.alreadyExists))
        loadingView?.display(EmailValidatorLoadingViewModel(isLoading: false))
    }
}
