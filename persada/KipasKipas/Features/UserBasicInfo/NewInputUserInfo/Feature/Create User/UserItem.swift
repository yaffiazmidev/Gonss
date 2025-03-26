//
//  UserItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct UserItem  {
    var accessToken, refreshToken: String
    var expiresIn: Int
    var role: String
    var userName, userEmail, userMobile, accountId: String
}
