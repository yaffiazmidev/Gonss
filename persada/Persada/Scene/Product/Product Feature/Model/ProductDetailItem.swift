//
//  ProductDetailItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ProductDetailItem {
    var id: String?
    var isDeleted: Bool?
    var name: String?
    var price: Int?
    var description: String?
    var sold: Bool?
    var measurement: ProductDetailItemMeasurement?
    var medias: [ProductDetailItemMedia]?
    var accountId, sellerName, generalStatus: String?
    var isBanned: Bool?
    var reasonBanned: String?
    var totalSales, stock: Int?
    var ratingAverage: Double?
    var ratingCount: Double?
    var city, productCategoryId, productCategoryName: String?
    var modal, commission: Double?
    var isResellerAllowed: Bool?
    var type: String?
    var isAlreadyReseller: Bool?
    var originalAccountId: String?
    
    init(id: String? = nil, isDeleted: Bool? = nil, name: String? = nil, price: Int? = nil, description: String? = nil, sold: Bool? = nil, measurement: ProductDetailItemMeasurement? = nil, medias: [ProductDetailItemMedia]? = nil, accountId: String? = nil, sellerName: String? = nil, generalStatus: String? = nil, isBanned: Bool? = nil, reasonBanned: String? = nil, totalSales: Int? = nil, stock: Int? = nil, ratingAverage: Double? = nil, ratingCount: Double? = nil, city: String? = nil, productCategoryId: String? = nil, productCategoryName: String? = nil, modal: Double? = nil, commission: Double? = nil, isResellerAllowed: Bool? = nil, type: String? = nil, isAlreadyReseller: Bool? = nil, originalAccountId: String? = nil) {
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
        self.stock = stock
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.city = city
        self.productCategoryId = productCategoryId
        self.productCategoryName = productCategoryName
        self.modal = modal
        self.commission = commission
        self.isResellerAllowed = isResellerAllowed
        self.type = type
        self.isAlreadyReseller = isAlreadyReseller
        self.originalAccountId = originalAccountId
    }
}

struct ProductDetailItemMeasurement{
    let weight, length, height, width: Double?
    
    init(weight: Double?, length: Double?, height: Double?, width: Double?) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

struct ProductDetailItemMedia{
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: ProductDetailItemMediaThumbnail?
    let metadata: ProductDetailItemMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    init(id: String?, type: String?, url: String?, thumbnail: ProductDetailItemMediaThumbnail?, metadata: ProductDetailItemMediaMetadata?, isHLSReady: Bool?, hlsURL: String?) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
    }
}

struct ProductDetailItemMediaMetadata {
    let width, height, size: String?
    let duration: Double?
    
    init(width: String?, height: String?, size: String?, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

struct ProductDetailItemMediaThumbnail {
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}
