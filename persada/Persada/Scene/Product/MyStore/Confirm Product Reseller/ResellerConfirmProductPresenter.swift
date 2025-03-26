//
//  ResellerConfirmProductPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ResellerConfirmProductPresenter {
    private let successView: ResellerConfirmProductView?
    private let errorView: ResellerConfirmProductLoadingErrorView?
    
    init(successView: ResellerConfirmProductView?, errorView: ResellerConfirmProductLoadingErrorView?) {
        self.successView = successView
        self.errorView = errorView
    }
    
    func didStartLoadingGetResellerConfirmProduct() {
        errorView?.display(.noError)
    }
    
    func didFinishLoadingGetResellerConfirmProduct(with item: ResellerProductDefaultItem) {
        successView?.display(ResellerConfirmProductViewModel(status: item.message))
    }
    
    func didFinishLoadingGetResellerConfirmProduct(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

protocol ResellerConfirmProductView {
    func display(_ viewModel: ResellerConfirmProductViewModel)
}

protocol ResellerConfirmProductLoadingErrorView {
    func display(_ viewModel: ResellerConfirmProductLoadingErrorViewModel)
}

struct ResellerConfirmProductViewModel {
    let status: String
}

struct ResellerConfirmProductLoadingErrorViewModel {
    let message: String?
    
    static var noError: ResellerConfirmProductLoadingErrorViewModel {
        return ResellerConfirmProductLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResellerConfirmProductLoadingErrorViewModel {
        return ResellerConfirmProductLoadingErrorViewModel(message: message)
    }
}
