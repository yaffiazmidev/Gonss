//
//  CourierViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct CourierViewModel {
    let items: [CourierItem]
}

struct CourierLoadingViewModel {
    let isLoading: Bool
}

struct CourierLoadingErrorViewModel {
    let message: String?
    
    static var noError: CourierLoadingErrorViewModel {
        return CourierLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> CourierLoadingErrorViewModel {
        return CourierLoadingErrorViewModel(message: message)
    }
}
