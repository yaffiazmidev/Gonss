//
//  FeedbackSenderViewModels.swift.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct FeedbackSenderViewModels {
    let item: FeedbackSenderItem
}

struct FeedbackSenderLoadingViewModel {
    let isLoading: Bool
}

struct FeedbackSenderLoadingErrorViewModel {
    let message: String?
    
    static var noError: FeedbackSenderLoadingErrorViewModel {
        return FeedbackSenderLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedbackSenderLoadingErrorViewModel {
        return FeedbackSenderLoadingErrorViewModel(message: message)
    }
}
