//
//  RemoteAuthOTPError.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteAuthOTPError: Codable {
    let code: String?
    let message: String?
    let data: RemoteAuthOTPErrorData?
    
    struct RemoteAuthOTPErrorData: Codable {
        let expireInSecond: Int?
        let tryInSecond: Int?
        let platform: String?
    }
}
