//
//  UpdateNotificationPreferencesViewModels.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct UpdateNotificationPreferencesViewModel {
    let item: NotificationPreferencesUpdateItem
}

struct UpdateNotificationPreferencesLoadingViewModel {
    let isLoading: Bool
}

struct UpdateNotificationPreferencesLoadingErrorViewModel {
    let message: String?
    let type: NotificationPreferencesType
    
    static var noError: UpdateNotificationPreferencesLoadingErrorViewModel {
        return UpdateNotificationPreferencesLoadingErrorViewModel(message: nil, type: .none)
    }
    
    static func error(message: String, type: NotificationPreferencesType) -> UpdateNotificationPreferencesLoadingErrorViewModel {
        return UpdateNotificationPreferencesLoadingErrorViewModel(message: message, type: type)
    }
}

enum NotificationPreferencesType {
    case social
    case shop
    case none
}
