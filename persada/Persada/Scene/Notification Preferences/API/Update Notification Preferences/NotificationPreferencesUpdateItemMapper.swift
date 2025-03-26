//
//  NotificationPreferencesUpdateItemMapper.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class NotificationPreferencesUpdateItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        
        var item: NotificationPreferencesUpdateItem {
            NotificationPreferencesUpdateItem(code: code, message: message)
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationPreferencesUpdateItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
