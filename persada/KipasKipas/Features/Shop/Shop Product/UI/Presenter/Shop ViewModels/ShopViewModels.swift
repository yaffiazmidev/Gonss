//
//  ShopViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ShopViewModel {
    let id: String
    let name: String
    let price: Double
    let ratingAverage: Double?
    let ratingCount: Int?
    let totalSales: Int?
    let metadataHeight: Double?
    let metadataWidth: Double?
    let city: String
    let isShowCity: Bool
    let imageURL: String
}

struct ShopLoadingViewModel {
    let isLoading: Bool
}

struct ShopLoadingErrorViewModel {
    let message: String?
    
    static var noError: ShopLoadingErrorViewModel {
        return ShopLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ShopLoadingErrorViewModel {
        return ShopLoadingErrorViewModel(message: message)
    }
}
