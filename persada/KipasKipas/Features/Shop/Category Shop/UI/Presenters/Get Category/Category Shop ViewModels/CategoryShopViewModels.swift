//
//  CategoryShopViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct CategoryShopViewModel {
    let items: [CategoryShopItem]
}

struct CategoryShopLoadingViewModel {
    let isLoading: Bool
}

struct CategoryShopLoadingErrorViewModel {
    let message: String?
    
    static var noError: CategoryShopLoadingErrorViewModel {
        return CategoryShopLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> CategoryShopLoadingErrorViewModel {
        return CategoryShopLoadingErrorViewModel(message: message)
    }
}
