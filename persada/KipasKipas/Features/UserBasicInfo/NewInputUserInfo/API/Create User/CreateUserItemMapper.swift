//
//  CreateUserItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class CreateUserItemMapper {
    private struct Root: Decodable {
        var accessToken, tokenType, loginRefreshToken: String
        var expiresIn: Int
        var scope: String
        var userNo: Int
        var userName, userEmail, userMobile, accountId: String
        var authorities: [String]
        var appSource, code: String
        var timelapse: Int
        var role, jti, token, refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case loginRefreshToken = "refresh_token"
            case expiresIn = "expires_in"
            case scope, userNo, userName, userEmail, userMobile, accountId, authorities, appSource, code, timelapse, role, jti, token, refreshToken
        }
        
        var item: UserItem {
            UserItem( accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, role: role, userName: userName, userEmail: userEmail, userMobile: userMobile, accountId: accountId)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> UserItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
