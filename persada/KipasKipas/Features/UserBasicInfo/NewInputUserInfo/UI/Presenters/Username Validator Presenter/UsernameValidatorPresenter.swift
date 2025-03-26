//
//  UsernameValidatorPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class UsernameValidatorPresenter {
    private let successView: UsernameValidatorView?
    private let loadingView: UsernameValidatorLoadingView?
    private let errorView: UsernameValidatorLoadingErrorView?
    private let alreadyExistsView: UsernameValidatorAlreadyExistsView?
    
    init(
        successView: UsernameValidatorView,
        loadingView: UsernameValidatorLoadingView,
        errorView: UsernameValidatorLoadingErrorView,
        alreadyExistsView: UsernameValidatorAlreadyExistsView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
            self.alreadyExistsView = alreadyExistsView
    }
    
    static var loadError: String {
        NSLocalizedString("USERNAME_VALIDATOR_GET_ERROR",
                          tableName: "InputUserWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    static var alreadyExists: String {
        NSLocalizedString("INPUT_USER_USERNAME_ALREADY_EXISTS",
                          tableName: "InputUserWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed username already exists from the server")
    }
    
    func didStartLoadingGetUsernameValidator() {
        errorView?.display(.noError)
        alreadyExistsView?.display(.noError)
        loadingView?.display(UsernameValidatorLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetUsernameValidator(with item: UsernameValidatorResponseItem) {
        successView?.display(UsernameValidatorViewModel(item: item))
        loadingView?.display(UsernameValidatorLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetUsernameValidator(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(UsernameValidatorLoadingViewModel(isLoading: false))
    }
    
    func didUsernameValidatorAlreadyExists(with error: Error) {
        alreadyExistsView?.display(.error(message: Self.alreadyExists))
        loadingView?.display(UsernameValidatorLoadingViewModel(isLoading: false))
    }
}
