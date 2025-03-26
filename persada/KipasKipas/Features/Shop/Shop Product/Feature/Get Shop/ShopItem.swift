//
//  ShopItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation


// MARK: - Content
struct ShopItem {
    let id: String?
    let isDeleted: Bool?
    let name: String?
    let price: Double?
    let description: String?
    let sold: Bool?
    let measurement: ShopItemMeasurement?
    let medias: [ShopItemMedia]?
    let accountId, sellerName, generalStatus: String?
    let isBanned: Bool?
    let reasonBanned: String?
    let totalSales, stock: Int?
    let ratingAverag: Double?
    let ratingCount: Int?
    let city: String?
}

// MARK: - ShopItemMeasurement
struct ShopItemMeasurement {
    let length, height, width, weight: Double?
}

// MARK: - ShopItemMedia
struct ShopItemMedia {
    let id, type: String?
    let url: String?
    let thumbnail: ShopItemThumbnail?
    let metadata: ShopItemMetadata?
    let isHlsReady: Bool?
    let hlsUrl: String?
}

// MARK: - ShopItemMetadata
struct ShopItemMetadata {
    let width, height, size: String?
    let duration: Double?
}

// MARK: - Thumbnail
struct ShopItemThumbnail {
    let large, medium, small: String?
}
