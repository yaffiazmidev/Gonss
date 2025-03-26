//
//  DetailTransactionDetailTransactionProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct DetailTransactionProductItem: Hashable {
    let id: String
    let isDeleted: Bool
    let name: String
    let price: Double
    let description: String
    let sold: Bool?
    let measurement: DetailTransactionProductItemMeasurement
    let medias: [DetailTransactionProductItemMedia]?
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
    
    init(id: String, isDeleted: Bool, name: String, price: Double, description: String, sold: Bool?, measurement: DetailTransactionProductItemMeasurement, medias: [DetailTransactionProductItemMedia]?, accountId: String, sellerName: String, generalStatus: String, isBanned: Bool, reasonBanned: String?, totalSales: Int, city: String?, stock: Int, productCategoryId: String?, productCategoryName: String?, modal: Double?, commission: Double?, isResellerAllowed: Bool, isAlreadyReseller: Bool, type: ProductType, ratingAverage: Double, ratingCount: Int, originalAccountId: String?) {
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
}

struct DetailTransactionProductItemMeasurement: Hashable{
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

struct DetailTransactionProductItemMedia: Hashable{
    let id: String
    let type: String
    let url: String
    let thumbnail: DetailTransactionProductItemMediaThumbnail?
    let metadata: DetailTransactionProductItemMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    init(id: String, type: String, url: String, thumbnail: DetailTransactionProductItemMediaThumbnail?, metadata: DetailTransactionProductItemMediaMetadata?, isHLSReady: Bool?, hlsURL: String?) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
    }
}

struct DetailTransactionProductItemMediaMetadata: Hashable {
    let width, height, size: String?
    let duration: Double?
    
    init(width: String?, height: String?, size: String?, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

struct DetailTransactionProductItemMediaThumbnail: Hashable {
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}

