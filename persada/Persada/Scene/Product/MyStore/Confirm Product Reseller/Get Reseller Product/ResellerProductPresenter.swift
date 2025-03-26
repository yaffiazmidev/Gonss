//
//  ResellerProductPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ResellerProductPresenter {
    private let successView: ResellerProductView?
    private let errorView: ResellerProductLoadingErrorView?
    
    init(successView: ResellerProductView?, errorView: ResellerProductLoadingErrorView?) {
        self.successView = successView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("RESELLER_VALIDATOR_GET_ERROR",
                          tableName: "UserSellerWords",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    func didStartLoadingGetResellerProduct() {
        errorView?.display(.noError)
    }
    
    func didFinishLoadingGetResellerProduct(with item: ResellerProductItem) {
        successView?.display(ResellerProductViewModel(item: item))
    }
    
    func didFinishLoadingGetResellerProduct(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

protocol ResellerProductView {
    func display(_ viewModel: ResellerProductViewModel)
}

protocol ResellerProductLoadingErrorView {
    func display(_ viewModel: ResellerProductLoadingErrorViewModel)
}

struct ResellerProductViewModel {
    let item: ResellerProductItem
}

struct ResellerProductLoadingErrorViewModel {
    let message: String?
    
    static var noError: ResellerProductLoadingErrorViewModel {
        return ResellerProductLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResellerProductLoadingErrorViewModel {
        return ResellerProductLoadingErrorViewModel(message: message)
    }
}
