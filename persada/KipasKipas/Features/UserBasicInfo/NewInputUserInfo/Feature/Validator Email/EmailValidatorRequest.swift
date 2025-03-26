//
//  EmailValidatorRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public struct EmailValidatorRequest: Encodable {
    let email: String
    
    init(email: String) {
        self.email = email
    }
}
