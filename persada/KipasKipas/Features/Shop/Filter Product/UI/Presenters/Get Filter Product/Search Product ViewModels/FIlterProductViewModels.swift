//
//  SearchProductViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct FilterProductViewModel {
    let id: String
    let name: String
    let price: Double
    let ratingAverage: Double?
    let ratingCount: Int?
    let totalSales: Int?
    let city: String
    let isShowCity: Bool
    let imageURL: String
    let metadataWidth, metadataHeight: Double
}

struct FilterProductLoadingViewModel {
    let isLoading: Bool
}

struct FilterProductLoadingErrorViewModel {
    let message: String?
    
    static var noError: FilterProductLoadingErrorViewModel {
        return FilterProductLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FilterProductLoadingErrorViewModel {
        return FilterProductLoadingErrorViewModel(message: message)
    }
}
