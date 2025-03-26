//
//  UsernameValidatorItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class UsernameValidatorItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: Bool
        
        var item: UsernameValidatorResponseItem {
            UsernameValidatorResponseItem(data: data)
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> UsernameValidatorResponseItem {
        if response.statusCode == 409 {
            throw KKNetworkError.usernameAlreadyExists
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
       
        
        return root.item
    }
}
