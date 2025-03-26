//
//  RemoteReviewMedia.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

// MARK: - RemoteReviewMedia
struct RemoteReviewMediaRoot: Codable {
    let code, message: String?
    let data: RemoteReviewMediaData?
}

// MARK: - DataClass
struct RemoteReviewMediaData: Codable {
    let content: [RemoteReviewMedia]?
    let pageable: RemoteReviewPageable?
    let totalElements, totalPages: Int?
    let last: Bool?
    let sort: RemoteReviewSort?
    let first: Bool?
    let numberOfElements, size, number: Int?
    let empty: Bool?
}

// MARK: - Content
struct RemoteReviewMedia: Codable {
    let id: String?
    let type, url: String
    let thumbnail: RemoteReviewMediaThumbnail?
    let metadata: RemoteReviewMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
    let username, photo: String?
    let isAnonymous: Bool?
    let review: String?
    let rating, createAt: Int?
    let productId: String
    let accountId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, url, thumbnail, metadata
        case isHLSReady = "isHlsReady"
        case hlsURL = "hlsUrl"
        case username, photo, isAnonymous, review, rating, createAt, productId, accountId
    }
}

// MARK: - Metadata
struct RemoteReviewMediaMetadata: Codable {
    let width, height, size: String?
    let duration: Double?
}

// MARK: - Thumbnail
struct RemoteReviewMediaThumbnail: Codable {
    let large, medium, small: String
}
