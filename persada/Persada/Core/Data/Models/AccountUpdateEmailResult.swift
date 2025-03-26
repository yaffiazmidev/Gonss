//
//  AccountUpdateEmailResult.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct AccountUpdateEmailResult: Codable {
    let code, message, data: String?
    
    enum CodingKeys: String, CodingKey {
            case code = "code"
            case message = "message"
            case data = "data"
    }
}
