//
//  TokenRefreshResponse.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 25/03/22.
//

import Foundation

public struct TokenItem: Hashable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Date
    
    public init(accessToken: String, refreshToken: String, expiresIn: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}
