//
//  AuthOTPBankAccountRequest.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct AuthOTPBankAccountRequest: Encodable {
    let phoneNumber: String
    let platform: String
}
