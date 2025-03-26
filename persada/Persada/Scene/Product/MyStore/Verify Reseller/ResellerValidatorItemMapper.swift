//
//  ResellerValidatorItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class ResellerValidatorItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: ResellerStatus?
        
        private struct ResellerStatus: Decodable {
            let follower, totalPost, shopDisplay: Bool?
        }
        
        var item: ResellerValidatorResponseItem {
            ResellerValidatorResponseItem(follower: data?.follower ?? false, totalPost: data?.totalPost ?? false, shopDisplay: data?.shopDisplay ?? false)
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ResellerValidatorResponseItem {
        if response.statusCode == 409 {
            throw KKNetworkError.notVerifyReseller
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}

struct ResellerValidatorRoot: Decodable {
    let code, message: String
    let data: ResellerStatus?
    
    struct ResellerStatus: Decodable {
        let follower, totalPost, shopDisplay: Bool?
    }
}
