//
//  CreateUserPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CreateUserPresenter {
    private let successView: CreateUserView?
    private let loadingView: CreateUserLoadingView?
    private let errorView: CreateUserLoadingErrorView?
    
    init(
        successView: CreateUserView,
        loadingView: CreateUserLoadingView,
        errorView: CreateUserLoadingErrorView) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("CREATE_USER_GET_ERROR",
                          tableName: "CreateUser",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    func didStartLoadingGetCreateUser() {
        errorView?.display(.noError)
        loadingView?.display(CreateUserLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetCreateUser(with item: UserItem) {
        successView?.display(CreateUserViewModel(item: item))
        loadingView?.display(CreateUserLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetCreateUser(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(CreateUserLoadingViewModel(isLoading: false))
    }
}
