//
//  LocalUserItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct LocalUserItem: Hashable  {
    let accessToken, refreshToken: String
    let expiresIn: String
    let role: String
    let userName, userEmail, userMobile, accountId: String
    
    init(accessToken: String, refreshToken: String, expiresIn: String, role: String, userName: String, userEmail: String, userMobile: String, accountId: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.role = role
        self.userName = userName
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.accountId = accountId
    }
}

extension LocalUserItem {
    func toDictionary() -> [KeychainLocalKeys: String] {
        return [
            .accessToken: accessToken,
            .refreshToken: refreshToken,
            .expiresIn: expiresIn,
            .username: userName,
            .phone: userMobile,
            .email: userEmail,
            .accountId: accountId,
            .role: role
        ]
    }
}



