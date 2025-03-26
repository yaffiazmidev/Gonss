//
//  STSTokenItemMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class STSTokenItemMapper {
    
    private struct Root: Decodable {
        let StatusCode: Int
        let AccessKeyId, AccessKeySecret, SecurityToken: String
        let Expiration: Date
        
        var item: STSTokenItem {
            STSTokenItem(
                securityToken: SecurityToken,
                accessKeyID: AccessKeyId,
                accessKeySecret: AccessKeySecret,
                expiration: Expiration
            )
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> STSTokenItem {
        print("**@@ mapper response \(String(describing: String(data: data, encoding: .utf8)))")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
