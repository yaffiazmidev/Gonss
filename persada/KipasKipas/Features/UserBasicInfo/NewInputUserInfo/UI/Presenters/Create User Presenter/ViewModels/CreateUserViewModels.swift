//
//  CreateUserViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct CreateUserViewModel {
    let item: UserItem
}

struct CreateUserLoadingViewModel {
    let isLoading: Bool
}

struct CreateUserLoadingErrorViewModel {
    let message: String?
    
    static var noError: CreateUserLoadingErrorViewModel {
        return CreateUserLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> CreateUserLoadingErrorViewModel {
        return CreateUserLoadingErrorViewModel(message: message)
    }
}
