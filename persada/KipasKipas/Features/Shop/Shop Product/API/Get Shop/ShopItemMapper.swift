//
//  ShopItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class ShopItemMapper {
    
    // MARK: - Store
    struct Root: Codable {
        let code, message: String?
        let data: ShopData?
        
        // MARK: - RecommendShopData
        struct ShopData: Codable {
            let content: [ShopContent]?
            let totalPages, totalElements: Int?
            let size, number: Int?
        }

        // MARK: - Content
        struct ShopContent: Codable {
            let id: String?
            let isDeleted: Bool?
            let name: String?
            let price: Double?
            let description: String?
            let sold: Bool?
            let measurement: ShopMeasurement?
            let medias: [ShopMedia]?
            let accountId, sellerName, generalStatus: String?
            let isBanned: Bool?
            let reasonBanned: String?
            let totalSales, stock: Int?
            let ratingAverag: Double?
            let ratingCount: Int?
            let city: String?
        }

        // MARK: - Measurement
        struct ShopMeasurement: Codable {
            let length, height, width, weight: Double?
        }

        // MARK: - Media
        struct ShopMedia: Codable {
            let id, type: String?
            let url: String?
            let thumbnail: Thumbnail?
            let metadata: Metadata?
            let isHlsReady: Bool?
            let hlsUrl: String?
        }

        // MARK: - Metadata
        struct ShopMetadata: Codable {
            let width, height, size: String?
            let duration: Double?
        }

        // MARK: - Thumbnail
        struct ShopThumbnail: Codable {
            let large, medium, small: String
        }
        
        var products: [ShopItem] {
            return data?.content?.compactMap {
                let measurement = ShopItemMeasurement(length: $0.measurement?.length, height: $0.measurement?.height, width: $0.measurement?.width, weight: $0.measurement?.weight)
                let medias = $0.medias?.compactMap {
                    let thumbnail = ShopItemThumbnail(large: $0.thumbnail?.large, medium: $0.thumbnail?.medium, small: $0.thumbnail?.small)
                    let metadata = ShopItemMetadata(width: $0.metadata?.width, height: $0.metadata?.height , size: $0.metadata?.size, duration: $0.metadata?.duration)
                    return ShopItemMedia(id: $0.id, type: $0.type, url: $0.type, thumbnail: thumbnail, metadata: metadata, isHlsReady: $0.isHlsReady, hlsUrl: $0.hlsUrl)
                }
                return ShopItem(
                    id : $0.id,
                    isDeleted : $0.isDeleted,
                    name : $0.name,
                    price : $0.price,
                    description : $0.description,
                    sold : $0.sold,
                    measurement : measurement,
                    medias: medias,
                    accountId: $0.accountId,
                    sellerName : $0.sellerName,
                    generalStatus : $0.generalStatus,
                    isBanned : $0.isBanned,
                    reasonBanned : $0.reasonBanned,
                    totalSales : $0.totalSales,
                    stock : $0.stock,
                    ratingAverag : $0.ratingAverag,
                    ratingCount : $0.ratingCount,
                    city: $0.city
                )
            } ?? []
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ShopItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.products
    }
}
