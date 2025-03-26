//
//  NotificationPreferencesUpdateRequest.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct NotificationPreferencesUpdateRequest: Encodable {
    let code: String
    let subCodes: SubCodes
    
    init(code: String, socialmedia: Bool, shop: Bool) {
        self.code = code
        self.subCodes = SubCodes(socialmedia: socialmedia, shop: shop)
    }
}

struct SubCodes: Encodable {
    let socialmedia: Bool
    let shop: Bool
}
