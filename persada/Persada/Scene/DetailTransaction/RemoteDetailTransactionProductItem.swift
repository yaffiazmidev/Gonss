//
//  RemoteDetailTransactionProductItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteDetailTransactionProductItem: Codable {
    let id: String?
    let isDeleted: Bool?
    let name: String?
    let price: Double?
    let description: String?
    let sold: Bool?
    let measurement: RemoteDetailTransactionProductItemMeasurement?
    let medias: [RemoteDetailTransactionProductItemMedia]?
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

struct RemoteDetailTransactionProductItemMeasurement: Codable{
    let weight: Double?
    let length: Int?
    let height: Int?
    let width: Int?
}

struct RemoteDetailTransactionProductItemMedia: Codable {
    let id: String?
    let type: String?
    let url: String?
    let thumbnail: RemoteDetailTransactionProductItemMediaThumbnail?
    let metadata: RemoteDetailTransactionProductItemMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
}

struct RemoteDetailTransactionProductItemMediaMetadata: Codable {
    let width, height, size: String?
    let duration: Double?
}

struct RemoteDetailTransactionProductItemMediaThumbnail: Codable {
    let large, medium, small: String?
}
