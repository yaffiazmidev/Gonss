//
//  CouriersTestPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CourierPresenter {
    
    private let successView: CourierView?
    private let loadingView: CourierLoadingView?
    private let errorView: CourierLoadingErrorView?
    
    init(
        successView: CourierView,
        loadingView: CourierLoadingView,
        errorView: CourierLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
    }
    
    func didStartLoadingGetCouriers() {
        errorView?.display(.noError)
        loadingView?.display(CourierLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetCouriers(with items: [CourierItem]) {
        successView?.display(CourierViewModel(items: items))
        loadingView?.display(CourierLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetCouriers(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(CourierLoadingViewModel(isLoading: false))
    }
}
