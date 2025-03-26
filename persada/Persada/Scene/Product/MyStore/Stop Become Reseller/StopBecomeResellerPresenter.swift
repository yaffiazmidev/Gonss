//
//  StopBecomeResellerPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class StopBecomeResellerPresenter {
    private let successView: StopBecomeResellerView?
    private let errorView: StopBecomeResellerLoadingErrorView?
    
    init(successView: StopBecomeResellerView?, errorView: StopBecomeResellerLoadingErrorView?) {
        self.successView = successView
        self.errorView = errorView
    }
    
    func didStartLoadingGetStopBecomeReseller() {
        errorView?.display(.noError)
    }
    
    func didFinishLoadingGetStopBecomeReseller(with item: ResellerProductDefaultItem) {
        successView?.display(StopBecomeResellerViewModel(item: item))
    }
    
    func didFinishLoadingGetStopBecomeReseller(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
    }
}

protocol StopBecomeResellerView {
    func display(_ viewModel: StopBecomeResellerViewModel)
}

protocol StopBecomeResellerLoadingErrorView {
    func display(_ viewModel: StopBecomeResellerLoadingErrorViewModel)
}

struct StopBecomeResellerViewModel {
    let item: ResellerProductDefaultItem
}

struct StopBecomeResellerLoadingErrorViewModel {
    let message: String?
    
    static var noError: StopBecomeResellerLoadingErrorViewModel {
        return StopBecomeResellerLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> StopBecomeResellerLoadingErrorViewModel {
        return StopBecomeResellerLoadingErrorViewModel(message: message)
    }
}
