//
//  TokenItemMapper.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

final class TokenItemMapper {

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteTokenItem {
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteTokenItem.self, from: data) else {
            if response.statusCode == 401 {
                throw KKNetworkError.tokenExpired
            } else {
                throw KKNetworkError.invalidData
            }
        }
        return root
    }
}
