//
//  ShopPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class ShopPresenter {
    
    private let successView: ShopView?
    private let loadingView: ShopLoadingView?
    private let errorView: ShopLoadingErrorView?
    
    init(
        successView: ShopView,
        loadingView: ShopLoadingView,
        errorView: ShopLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
    }
    
    func didStartLoadingGetShop() {
        errorView?.display(.noError)
        loadingView?.display(ShopLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetShop(with items: [ShopItem]) {
        let validItems = items.map {
            let isShowCity = $0.city != nil
            return ShopViewModel(id: $0.id ?? "", name: $0.name ?? "", price: $0.price ?? 0.0, ratingAverage: $0.ratingAverag, ratingCount: $0.ratingCount, totalSales: $0.totalSales, metadataHeight: Double($0.medias?.first?.metadata?.height ?? ""), metadataWidth: Double($0.medias?.first?.metadata?.width ?? ""), city: $0.city ?? "", isShowCity: isShowCity, imageURL: $0.medias?.first?.thumbnail?.medium ?? "")
        }
        
        successView?.display(validItems)
        loadingView?.display(ShopLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetShop(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(ShopLoadingViewModel(isLoading: false))
    }
}
