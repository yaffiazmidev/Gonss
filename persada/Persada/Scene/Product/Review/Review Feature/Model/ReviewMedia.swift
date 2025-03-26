//
//  ReviewMediaItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

// MARK: - DataClass
struct ReviewMediaData: Hashable, Encodable {
    let content: [ReviewMedia]
    let totalElements, totalPages: Int
    let last: Bool
    let first: Bool
    
    
    init(content: [ReviewMedia], totalElements: Int, totalPages: Int, last: Bool, first: Bool) {
        self.content = content
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.last = last
        self.first = first
    }
}

// MARK: - ReviewMedia
struct ReviewMedia: Hashable, Encodable {
    let id: String?
    let type: String
    let url: String
    let thumbnail: ReviewMediaThumbnail?
    let metadata: ReviewMediaMetadata?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    let username, photo, accountId: String
    let isAnonymous: Bool
    let review: String?
    let rating: Int
    let createAt: Int
    let vodFileId: String?
    let vodUrl: String?
    
    init(id: String?, type: String, url: String, thumbnail: ReviewMediaThumbnail?, metadata: ReviewMediaMetadata?, isHLSReady: Bool?, hlsURL: String?, username: String, photo: String, accountId: String, isAnonymous: Bool, review: String?, rating: Int, createAt: Int, vodFileId: String? = nil, vodUrl: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
        self.username = username
        self.accountId = accountId
        self.photo = photo
        self.isAnonymous = isAnonymous
        self.review = review
        self.rating = rating
        self.createAt = createAt
        self.vodFileId = vodFileId
        self.vodUrl = vodUrl
    }
    
    func toReviewItem() -> ReviewItem{
        return ReviewItem(username: self.username, photo: self.photo, accountId: self.accountId, medias: [], isAnonymous: self.isAnonymous, review: self.review, rating: self.rating, createAt: self.createAt, urlBadge: nil, isShowBadge: false)
    }
}

// MARK: - Metadata
struct ReviewMediaMetadata: Hashable, Encodable {
    let width, height, size: String
    let duration: Double?
    
    init(width: String, height: String, size: String, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

// MARK: - Thumbnail
struct ReviewMediaThumbnail: Hashable, Encodable {
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}
