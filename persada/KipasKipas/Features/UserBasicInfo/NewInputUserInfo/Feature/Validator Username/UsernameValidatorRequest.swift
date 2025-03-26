//
//  UsernameValidatorRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct UsernameValidatorRequest: Encodable {
    let username: String
    
    init(username: String) {
        self.username = username
    }
}
