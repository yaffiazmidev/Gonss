//
//  QRProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct QRProductItem {
    let id: String?
    let isDeleted: Bool?
    let name: String?
    let price: Int?
    let description: String?
    let sold: Bool?
    let measurement: QRProductMeasurementItem?
    let medias: [QRProductMediaItem]?
    let accountId, sellerName, generalStatus: String?
    let isBanned: Bool?
    let reasonBanned: String?
    let totalSales, stock: Int?
    let ratingAverage: Double?
    let ratingCount: Double?
    let city, productCategoryId, productCategoryName: String?
    let modal, commission: Double?
    let isResellerAllowed: Bool?
    let type: String?
    let isAlreadyReseller: Bool?
    let originalAccountId: String?
    
    init(id: String?, isDeleted: Bool?, name: String?, price: Int?, description: String?, sold: Bool?, measurement: QRProductMeasurementItem?, medias: [QRProductMediaItem]?, accountId: String?, sellerName: String?, generalStatus: String?, isBanned: Bool?, reasonBanned: String?, totalSales: Int?, stock: Int?, ratingAverage: Double?, ratingCount: Double?, city: String?, productCategoryId: String?, productCategoryName: String?, modal: Double?, commission: Double?, isResellerAllowed: Bool?, type: String?, isAlreadyReseller: Bool?, originalAccountId: String?) {
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

struct QRProductMeasurementItem{
    let weight, length, height, width: Double?
    
    init(weight: Double?, length: Double?, height: Double?, width: Double?) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

struct QRProductMediaItem{
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: QRProductMediaThumbnailItem?
    let metadata: QRProductMediaMetadataItem?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    init(id: String?, type: String?, url: String?, thumbnail: QRProductMediaThumbnailItem?, metadata: QRProductMediaMetadataItem?, isHLSReady: Bool?, hlsURL: String?) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
    }
}

struct QRProductMediaMetadataItem {
    let width, height, size: String?
    let duration: Double?
    
    init(width: String?, height: String?, size: String?, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

struct QRProductMediaThumbnailItem {
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}
