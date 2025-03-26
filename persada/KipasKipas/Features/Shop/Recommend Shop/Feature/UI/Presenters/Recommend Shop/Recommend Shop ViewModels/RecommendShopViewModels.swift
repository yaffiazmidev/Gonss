//
//  RecommendShopViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RecommendShopViewModel {
    let id: String
    let name: String
    let price: Double
    let ratingAverage: Double?
    let ratingCount: Int?
    let totalSales: Int?
    let city: String
    let isShowCity: Bool
    let imageURL: String
}

struct RecommendShopLoadingViewModel {
    let isLoading: Bool
}

struct RecommendShopLoadingErrorViewModel {
    let message: String?
    
    static var noError: RecommendShopLoadingErrorViewModel {
        return RecommendShopLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> RecommendShopLoadingErrorViewModel {
        return RecommendShopLoadingErrorViewModel(message: message)
    }
}
