//
//  FilterProductPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class FilterProductPresenter {
    
    private let successView: FilterProductView?
    private let loadingView: FilterProductLoadingView?
    private let errorView: FilterProductLoadingErrorView?
    
    init(
        successView: FilterProductView,
        loadingView: FilterProductLoadingView,
        errorView: FilterProductLoadingErrorView) {
            self.successView = successView
            self.loadingView = loadingView
            self.errorView = errorView
    }
    
    func didStartLoadingGetFilterProduct() {
        errorView?.display(.noError)
        loadingView?.display(FilterProductLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetFilterProduct(with items: [ShopItem]) {
        let validItems = items.map {
            let isShowCity = $0.city != nil
            return FilterProductViewModel(id: $0.id ?? "", name: $0.name ?? "", price: $0.price ?? 0.0, ratingAverage: $0.ratingAverag, ratingCount: $0.ratingCount, totalSales: $0.totalSales, city: $0.city ?? "", isShowCity: isShowCity, imageURL: $0.medias?.first?.thumbnail?.medium ?? "", metadataWidth: Double($0.medias?.first?.metadata?.width ?? "1028") ?? 1028.0, metadataHeight: Double($0.medias?.first?.metadata?.height ?? "1028") ?? 1028.0)
        }
        
        successView?.display(validItems)
        loadingView?.display(FilterProductLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetFilterProduct(with error: Error) {
        errorView?.display(.error(message: error.localizedDescription))
        loadingView?.display(FilterProductLoadingViewModel(isLoading: false))
    }
}
