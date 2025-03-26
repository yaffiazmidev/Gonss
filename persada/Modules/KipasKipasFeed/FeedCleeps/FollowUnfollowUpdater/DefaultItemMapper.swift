//
//  DefaultItemMapper.swift
//  FeedCleeps
//
//  Created by DENAZMI on 05/12/22.
//

import Foundation
import KipasKipasNetworking

public struct DefaultItem: Codable {
    let code, data, message: String?
}

class DefaultItemMapper {
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> DefaultItem {
        guard response.isOK, let root = try? JSONDecoder().decode(DefaultResponse.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        return DefaultItem(code: root.code, data: root.data, message: root.message)
    }
}
