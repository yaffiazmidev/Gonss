//
//  ProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteProductItem: Codable {
    let id: String?
    let isDeleted: Bool?
    let name: String?
    let price: Double?
    let description: String?
    let sold: Bool?
    let measurement: RemoteProductItemMeasurement?
    let medias: [RemoteProductItemMedia]?
    let accountId : String?
    let sellerName : String?
    let generalStatus : String?
    let isBanned : Bool?
    let reasonBanned: String?
    let totalSales : Int?
    let city : String?
    let stock : Int?
    let productCategoryId : String?
    let productCategoryName : String?
    let modal: Double?
    let commission: Double?
    let isResellerAllowed: Bool?
    let isAlreadyReseller: Bool?
    let type: String?
    let ratingAverage: Double?
    let ratingCount: Int?
    let originalAccountId: String?
}

struct RemoteProductItemMeasurement: Codable{
    let weight: Double?
    let length: Int?
    let height: Int?
    let width: Int?
}

struct RemoteProductItemMedia: Codable {
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: RemoteProductItemMediaThumbnail?
    let metadata: RemoteProductItemMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
}

struct RemoteProductItemMediaMetadata: Codable {
    let width, height, size: String?
    let duration: Double?
}

struct RemoteProductItemMediaThumbnail: Codable {
    let large, medium, small: String?
}
