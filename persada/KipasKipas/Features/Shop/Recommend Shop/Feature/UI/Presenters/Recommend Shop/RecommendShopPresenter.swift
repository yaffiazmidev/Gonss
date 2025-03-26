//
//  RecommendShopPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class RecommendShopPresenter {
    
    private let successView: RecommendShopView?
    private let loadingView: RecommendShopLoadingView?
    private let errorView: RecommendShopLoadingErrorView?
    
    init(
        successView: RecommendShopView,
        loadingView: RecommendShopLoadingView,
        errorView: RecommendShopLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
    }
    
    func didStartLoadingGetRecommendShop() {
        errorView?.display(.noError)
        loadingView?.display(RecommendShopLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetRecommendShop(with items: [ShopItem]) {
        let validItems = items.map {
            let isShowCity = $0.city != nil
            return RecommendShopViewModel(id: $0.id ?? "", name: $0.name ?? "", price: $0.price ?? 0.0, ratingAverage: $0.ratingAverag, ratingCount: $0.ratingCount, totalSales: $0.totalSales, city: $0.city ?? "", isShowCity: isShowCity, imageURL: $0.medias?.first?.thumbnail?.medium ?? "")
        }
        
        successView?.display(validItems)
        loadingView?.display(RecommendShopLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetRecommendShop(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(RecommendShopLoadingViewModel(isLoading: false))
    }
}
