//
//  CategoryShopItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class CategoryShopItemMapper {

    private struct Root: Decodable {
        private let data: [CategoryShop]
        
        private struct CategoryShop: Decodable {
            let id, name: String
            let sequence: Int?
            let totalProduct: Int
            let icon, description: String
        }
        
        var category: [CategoryShopItem] {
            return data.compactMap {
                return CategoryShopItem(id: $0.id, name: $0.name, sequence: $0.sequence ?? 0, totalProduct: $0.totalProduct, icon: $0.icon, description: $0.description)
            }
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CategoryShopItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.category
    }
}
