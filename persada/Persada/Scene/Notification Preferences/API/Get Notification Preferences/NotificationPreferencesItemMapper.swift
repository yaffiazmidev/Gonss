//
//  NotificationPreferencesItemMapper.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class NotificationPreferencesItemMapper {
    
    private struct RemoteNotificationPreferences: Decodable {
        private let code, message: String
        private let data: RemoteNotificationPreferencesData
        
        private struct RemoteNotificationPreferencesData: Decodable {
            let subCodes: RemoteNotificationPreferencesSubCodes
        }

        private struct RemoteNotificationPreferencesSubCodes: Decodable {
            let socialmedia, shop: Bool
        }
        
        var item: NotificationPreferencesItem {
            NotificationPreferencesItem(socialMediaPreferences: data.subCodes.socialmedia, shopPreferences: data.subCodes.shop)
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationPreferencesItem {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteNotificationPreferences.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
