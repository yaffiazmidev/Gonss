//
//  ResellerProductItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class ResellerProductItemMapper {
    private struct Root: Decodable {
        let code : String?
        let data : ResellerProduct?
        let message : String?
     
        struct ResellerProduct: Codable {
            var id : String?
            var name : String?
            var price : Double?
            var sellerName : String?
            var modal: Double?
            var commission: Double?
            var isAlreadyReseller: Bool?
        }
        
        var item: ResellerProductItem {
            return ResellerProductItem(productName: data?.name, price: data?.price, commission: data?.commission, isAlreadyReseller: data?.isAlreadyReseller ?? false, sellerName: data?.sellerName)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ResellerProductItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
