//
//  CategoryShopPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class CategoryShopPresenter {
    
    private let successView: CategoryShopView?
    private let loadingView: CategoryShopLoadingView?
    private let errorView: CategoryShopLoadingErrorView?
    
    init(
        successView: CategoryShopView,
        loadingView: CategoryShopLoadingView,
        errorView: CategoryShopLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
    }
    
    func didStartLoadingGetCategoryShop() {
        errorView?.display(.noError)
        loadingView?.display(CategoryShopLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetCategoryShop(with items: [CategoryShopItem]) {
        successView?.display(CategoryShopViewModel(items: items))
        loadingView?.display(CategoryShopLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetCategoryShop(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(CategoryShopLoadingViewModel(isLoading: false))
    }
}
