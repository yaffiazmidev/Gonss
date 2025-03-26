//
//  UserSellerPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

final class UserSellerPresenter {
    private let successView: UserSellerView?
    private let errorView: UserSellerLoadingErrorView?
    
    init(successView: UserSellerView?, errorView: UserSellerLoadingErrorView?) {
        self.successView = successView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("RESELLER_VALIDATOR_GET_ERROR",
                          tableName: "UserSellerWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    func didStartLoadingGetUserSeller() {
        errorView?.display(.noError)
    }
    
    func didFinishLoadingGetUserSeller(with item: UserSellerItem) {
        successView?.display(UserSellerViewModel(item: item))
    }
    
    func didFinishLoadingGetUserSeller(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

protocol UserSellerView {
    func display(_ viewModel: UserSellerViewModel)
}

protocol UserSellerLoadingErrorView {
    func display(_ viewModel: UserSellerLoadingErrorViewModel)
}

struct UserSellerViewModel {
    let item: UserSellerItem
}

struct UserSellerLoadingErrorViewModel {
    let message: String?
    
    static var noError: UserSellerLoadingErrorViewModel {
        return UserSellerLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> UserSellerLoadingErrorViewModel {
        return UserSellerLoadingErrorViewModel(message: message)
    }
}
