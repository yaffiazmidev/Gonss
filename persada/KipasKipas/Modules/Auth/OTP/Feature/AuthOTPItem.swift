//
//  AuthOTPItem.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct AuthOTPItem {
    let expireInSecond: Int?
    let tryInSecond: Int?
    let platform: String
    let code: Int
    let message: String
}
