//
//  UserPhotoUploadViewModels.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct UserPhotoUploadViewModel {
    let item: UserPhotoItem
}

struct UserPhotoUploadLoadingViewModel {
    let isLoading: Bool
}

struct UserPhotoUploadLoadingErrorViewModel {
    let message: String?
    
    static var noError: UserPhotoUploadLoadingErrorViewModel {
        return UserPhotoUploadLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> UserPhotoUploadLoadingErrorViewModel {
        return UserPhotoUploadLoadingErrorViewModel(message: message)
    }
}
