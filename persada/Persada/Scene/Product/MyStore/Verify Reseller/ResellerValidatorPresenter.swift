//
//  ResellerValidatorPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ResellerValidatorPresenter {
    private let successView: ResellerValidatorView?
    private let errorView: ResellerValidatorLoadingErrorView?
    
    init(successView: ResellerValidatorView?, errorView: ResellerValidatorLoadingErrorView?) {
        self.successView = successView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("RESELLER_VALIDATOR_GET_ERROR",
                          tableName: "ResellerValidatorWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    func didStartLoadingGetResellerValidator() {
        errorView?.display(.noError)
    }
    
    func didFinishLoadingGetResellerValidator(with item: ResellerValidatorResponseItem) {
        successView?.display(ResellerValidatorViewModel(item: item))
    }
    
    func didFinishLoadingGetResellerValidator(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
    }
}

protocol ResellerValidatorView {
    func display(_ viewModel: ResellerValidatorViewModel)
}

protocol ResellerValidatorLoadingErrorView {
    func display(_ viewModel: ResellerValidatorLoadingErrorViewModel)
}

struct ResellerValidatorViewModel {
    let item: ResellerValidatorResponseItem
}

struct ResellerValidatorLoadingErrorViewModel {
    let message: String?
    
    static var noError: ResellerValidatorLoadingErrorViewModel {
        return ResellerValidatorLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResellerValidatorLoadingErrorViewModel {
        return ResellerValidatorLoadingErrorViewModel(message: message)
    }
}
