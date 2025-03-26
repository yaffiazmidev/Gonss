//
//  ProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ProductArrayItem: Hashable {
    let data: [ProductItem]
    let totalPages: Int
    
    init(data: [ProductItem], totalPages: Int) {
        self.data = data
        self.totalPages = totalPages
    }
}

struct ProductItem: Hashable {
    let id: String
    let isDeleted: Bool
    let name: String
    let price: Double
    let description: String
    let sold: Bool?
    let measurement: ProductItemMeasurement
    let medias: [ProductItemMedia]?
    let accountId : String
    let sellerName : String
    let generalStatus : String
    let isBanned : Bool
    let reasonBanned: String?
    let totalSales : Int
    let city : String?
    let stock : Int
    let productCategoryId : String?
    let productCategoryName : String?
    let modal: Double?
    let commission: Double?
    let isResellerAllowed: Bool
    let isAlreadyReseller: Bool
    let type: ProductType
    let ratingAverage: Double
    let ratingCount: Int
    let originalAccountId: String?
    
    init(id: String, isDeleted: Bool, name: String, price: Double, description: String, sold: Bool?, measurement: ProductItemMeasurement, medias: [ProductItemMedia]?, accountId: String, sellerName: String, generalStatus: String, isBanned: Bool, reasonBanned: String?, totalSales: Int, city: String?, stock: Int, productCategoryId: String?, productCategoryName: String?, modal: Double?, commission: Double?, isResellerAllowed: Bool, isAlreadyReseller: Bool, type: ProductType, ratingAverage: Double, ratingCount: Int, originalAccountId: String?) {
        self.id = id
        self.isDeleted = isDeleted
        self.name = name
        self.price = price
        self.description = description
        self.sold = sold
        self.measurement = measurement
        self.medias = medias
        self.accountId = accountId
        self.sellerName = sellerName
        self.generalStatus = generalStatus
        self.isBanned = isBanned
        self.reasonBanned = reasonBanned
        self.totalSales = totalSales
        self.city = city
        self.stock = stock
        self.productCategoryId = productCategoryId
        self.productCategoryName = productCategoryName
        self.modal = modal
        self.commission = commission
        self.isResellerAllowed = isResellerAllowed
        self.isAlreadyReseller = isAlreadyReseller
        self.type = type
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.originalAccountId = originalAccountId
    }
    
    func toProduct() -> Product {
        let medias: [Medias] = medias?.map ({ media in
            Medias(
                id: media.id,
                type: media.type,
                url: media.url,
                isHlsReady: media.isHLSReady,
                thumbnail: Thumbnail(
                    large: media.thumbnail?.large,
                    medium: media.thumbnail?.medium,
                    small: media.thumbnail?.small
                ),
                metadata: Metadata(
                    width: media.metadata?.width,
                    height: media.metadata?.height,
                    size: media.metadata?.size,
                    duration: media.metadata?.duration
                )
            )
        }) ?? []
        
        return Product(
            accountId: accountId,
            postProductDescription: description,
            generalStatus: generalStatus,
            id: id,
            isDeleted: isDeleted,
            measurement: ProductMeasurement(
                weight: measurement.weight,
                length: Double(measurement.length),
                height: Double(measurement.height),
                width: Double(measurement.width)
            ),
            medias: medias,
            name: name,
            price: price,
            stock: stock,
            sellerName: sellerName,
            sold: sold,
            productPages: nil,
            reasonBanned: reasonBanned,
            totalSales: totalSales,
            city: city,
            ratingAverage: ratingAverage,
            ratingCount: ratingCount,
            categoryId: productCategoryId,
            categoryName: productCategoryName,
            isResellerAllowed: isResellerAllowed,
            isAlreadyReseller: isAlreadyReseller,
            type: type.rawValue,
            originalAccountId: originalAccountId
        )
    }
    
    static func fromProduct(_ product: Product) -> ProductItem {
        let medias: [ProductItemMedia] = product.medias?.map({ media in
            ProductItemMedia(
                id: media.id ?? "",
                type: media.type ?? "",
                url: media.url ?? "",
                thumbnail: ProductItemMediaThumbnail(
                    large: media.thumbnail?.large,
                    medium:  media.thumbnail?.medium,
                    small: media.thumbnail?.small
                ),
                metadata: ProductItemMediaMetadata(
                    width: media.metadata?.width,
                    height: media.metadata?.height,
                    size: media.metadata?.size,
                    duration: media.metadata?.duration
                ),
                isHLSReady: media.isHlsReady,
                hlsURL: media.hlsUrl
            )
        }) ?? []
        
        return ProductItem(
            id: product.id ?? "",
            isDeleted: product.isDeleted ?? false,
            name: product.name ?? "",
            price: product.price ?? 0,
            description: product.postProductDescription ?? "",
            sold: product.sold,
            measurement: ProductItemMeasurement(
                weight: product.measurement?.weight ?? 0,
                length: Int(product.measurement?.length ?? 0),
                height: Int(product.measurement?.height ?? 0),
                width: Int(product.measurement?.width ?? 0)
            ),
            medias: medias,
            accountId: product.accountId ?? "",
            sellerName: product.sellerName ?? "",
            generalStatus: product.generalStatus ?? "",
            isBanned: !product.reasonBanned.isNilOrEmpty,
            reasonBanned: product.reasonBanned,
            totalSales: product.totalSales ?? 0,
            city: product.city,
            stock: product.stock ?? 0,
            productCategoryId: product.categoryId,
            productCategoryName: product.categoryName,
            modal: product.modal,
            commission: product.commission,
            isResellerAllowed: product.isResellerAllowed ?? false,
            isAlreadyReseller: product.isAlreadyReseller ?? false,
            type: ProductType(rawValue: product.type ?? "") ?? .original,
            ratingAverage: product.ratingAverage ?? 0,
            ratingCount: product.ratingCount ?? 0,
            originalAccountId: product.originalAccountId
        )
    }
}

struct ProductItemMeasurement: Hashable{
    let weight: Double
    let length: Int
    let height: Int
    let width: Int
    
    init(weight: Double, length: Int, height: Int, width: Int) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

struct ProductItemMedia: Hashable{
    let id: String
    let type: String
    let url: String
    let thumbnail: ProductItemMediaThumbnail?
    let metadata: ProductItemMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    init(id: String, type: String, url: String, thumbnail: ProductItemMediaThumbnail?, metadata: ProductItemMediaMetadata?, isHLSReady: Bool?, hlsURL: String?) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
    }
}

struct ProductItemMediaMetadata: Hashable {
    let width, height, size: String?
    let duration: Double?
    
    init(width: String?, height: String?, size: String?, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

struct ProductItemMediaThumbnail: Hashable {
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}
