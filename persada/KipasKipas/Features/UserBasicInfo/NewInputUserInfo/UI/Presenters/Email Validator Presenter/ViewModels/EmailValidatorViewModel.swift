//
//  EmailValidatorViewModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct EmailValidatorViewModel {
    let item: EmailValidatorResponseItem
}

struct EmailValidatorLoadingViewModel {
    let isLoading: Bool
}

struct EmailValidatorLoadingErrorViewModel {
    let message: String?
    
    static var noError: EmailValidatorLoadingErrorViewModel {
        return EmailValidatorLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> EmailValidatorLoadingErrorViewModel {
        return EmailValidatorLoadingErrorViewModel(message: message)
    }
}

struct EmailValidatorAlreadyExistsViewModel {
    let message: String?
    
    static var noError: EmailValidatorAlreadyExistsViewModel {
        return EmailValidatorAlreadyExistsViewModel(message: nil)
    }
    
    static func error(message: String) -> EmailValidatorAlreadyExistsViewModel {
        return EmailValidatorAlreadyExistsViewModel(message: message)
    }
}
