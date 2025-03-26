//
//  RemoteQRProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteQRProductItemRoot: Codable {
    let code, message: String?
    let data: RemoteQRProductItem?
}

struct RemoteQRProductItem: Codable {
    let id: String?
    let isDeleted: Bool?
    let name: String?
    let price: Int?
    let description: String?
    let sold: Bool?
    let measurement: RemoteQRProductMeasurementItem?
    let medias: [RemoteQRProductMediaItem]?
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
}

struct RemoteQRProductMeasurementItem: Codable{
    let weight, length, height, width: Double?
}

struct RemoteQRProductMediaItem: Codable{
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: RemoteQRProductMediaThumbnailItem?
    let metadata: RemoteQRProductMediaMetadataItem?
    let isHLSReady: Bool?
    let hlsURL: String?
}

struct RemoteQRProductMediaMetadataItem: Codable {
    let width, height, size: String?
    let duration: Double?
}

struct RemoteQRProductMediaThumbnailItem: Codable {
    let large, medium, small: String?
}
