//
//  UsernameValidatorViewModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct UsernameValidatorViewModel {
    let item: UsernameValidatorResponseItem
}

struct UsernameValidatorLoadingViewModel {
    let isLoading: Bool
}

struct UsernameValidatorLoadingErrorViewModel {
    let message: String?
    
    static var noError: UsernameValidatorLoadingErrorViewModel {
        return UsernameValidatorLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> UsernameValidatorLoadingErrorViewModel {
        return UsernameValidatorLoadingErrorViewModel(message: message)
    }
}


struct UsernameValidatorAlreadyExistsViewModel {
    let message: String?

    static var noError: UsernameValidatorAlreadyExistsViewModel {
        return UsernameValidatorAlreadyExistsViewModel(message: nil)
    }
    
    static func error(message: String) -> UsernameValidatorAlreadyExistsViewModel {
        return UsernameValidatorAlreadyExistsViewModel(message: message)
    }
}
