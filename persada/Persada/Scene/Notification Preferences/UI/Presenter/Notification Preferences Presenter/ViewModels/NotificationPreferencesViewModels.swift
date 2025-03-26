//
//  NotificationPreferencesViewModels.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct NotificationPreferencesViewModel {
    let item: NotificationPreferencesItem
}

struct NotificationPreferencesLoadingViewModel {
    let isLoading: Bool
}

struct NotificationPreferencesLoadingErrorViewModel {
    let message: String?
    
    static var noError: NotificationPreferencesLoadingErrorViewModel {
        return NotificationPreferencesLoadingErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NotificationPreferencesLoadingErrorViewModel {
        return NotificationPreferencesLoadingErrorViewModel(message: message)
    }
}
