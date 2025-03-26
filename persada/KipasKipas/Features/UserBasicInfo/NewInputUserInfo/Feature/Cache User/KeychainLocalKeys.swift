//
//  KeychainLocalKeys.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum KeychainLocalKeys: String {
    case accessToken = "user_access_token_key"
    case refreshToken = "user_refresh_token_key"
    case expiresIn = "user_expires_in_key"
    case username = "user_username_key"
    case email = "user_useremail_key"
    case phone = "user_usermobile_key"
    case avatar = "user_avatar_key"
    case accountId = "user_account_id_key"
    case role = "user_role_key"
}
