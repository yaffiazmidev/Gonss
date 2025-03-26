//
//  CourierItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class CourierItemMapper {
    
    private struct Root: Codable {
        private let code, message: String
        private let data: CourierData?
        
        private struct CourierData: Codable {
            let origin, destination: String?
            let courier: [Courier]?
        }

        private struct Courier : Codable {
            let duration : String?
            let name : String?
            let prices : [CourierPrice]?
        }
        
        var courier: [CourierItem] {
            return data?.courier?.flatMap({
                let prices = $0.prices?.flatMap({ item in
                    return CourierItemPrice(duration: item.duration, price: item.price, service: item.service)
                })
                return CourierItem(name: $0.name, prices: prices)
            }) ?? []
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CourierItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.courier
    }
}
