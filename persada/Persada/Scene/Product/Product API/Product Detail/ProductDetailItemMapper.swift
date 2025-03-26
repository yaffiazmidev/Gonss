//
//  ProductDetailItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class ProductDetailItemMapper {

    private struct Root: Decodable {
        let code, message: String?
        let data: ProductDetail?
        
        struct ProductDetail: Decodable {
            let id: String?
            let isDeleted: Bool?
            let name: String?
            let price: Int?
            let description: String?
            let sold: Bool?
            let measurement: ProductDetailMeasurement?
            let medias: [ProductDetailMedia]?
            let accountId, sellerName, generalStatus: String?
            let isBanned: Bool?
            let reasonBanned: String?
            let totalSales, stock: Int?
            let ratingAverage, ratingCount: Double?
            let city, productCategoryId, productCategoryName: String?
            let modal, commission: Double?
            let isResellerAllowed: Bool?
            let type: String?
            let isAlreadyReseller: Bool?
            let originalAccountId: String?
        }
        
        struct ProductDetailMeasurement: Decodable {
            let weight, length, height, width: Double?
        }
        
        struct ProductDetailMedia: Decodable {
            let id, type: String?
            let url: String?
            let thumbnail: ProductDetailThumbnail?
            let metadata: ProductDetailMetadata?
            let isHlsReady: Bool?
            let hlsUrl: String?
        }
        
        struct ProductDetailMetadata: Codable {
            let width, height, size: String?
            let duration: Double?
        }
        
        struct ProductDetailThumbnail: Codable {
            let large, medium, small: String?
        }
        
        var item: ProductDetailItem {
            let measurement = ProductDetailItemMeasurement(weight: data?.measurement?.weight, length: data?.measurement?.length, height: data?.measurement?.height, width: data?.measurement?.width)
            let medias: [ProductDetailItemMedia] = data?.medias?.compactMap {
                let thumbnail = ProductDetailItemMediaThumbnail(large: $0.thumbnail?.large, medium: $0.thumbnail?.medium, small: $0.thumbnail?.small)
                let metadata = ProductDetailItemMediaMetadata(width: $0.metadata?.width, height: $0.metadata?.height , size: $0.metadata?.size, duration: $0.metadata?.duration)
                return ProductDetailItemMedia(id: $0.id, type: $0.type, url: $0.type, thumbnail: thumbnail, metadata: metadata, isHLSReady: $0.isHlsReady, hlsURL: $0.hlsUrl)
            } ?? []
            
            return ProductDetailItem(
                id: data?.id,
                isDeleted: data?.isDeleted,
                name: data?.name,
                price: data?.price,
                description: data?.description,
                sold: data?.sold,
                measurement: measurement,
                medias: medias,
                accountId: data?.accountId,
                sellerName: data?.sellerName,
                generalStatus: data?.generalStatus,
                isBanned: data?.isBanned,
                reasonBanned: data?.reasonBanned,
                totalSales: data?.totalSales,
                stock: data?.stock,
                ratingAverage : data?.ratingAverage,
                ratingCount: data?.ratingCount,
                city: data?.city,
                productCategoryId: data?.productCategoryId,
                productCategoryName: data?.productCategoryName,
                modal: data?.modal,
                commission: data?.commission,
                isResellerAllowed: data?.isResellerAllowed,
                type: data?.type,
                isAlreadyReseller: data?.isAlreadyReseller,
                originalAccountId: data?.originalAccountId
            )
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> ProductDetailItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
