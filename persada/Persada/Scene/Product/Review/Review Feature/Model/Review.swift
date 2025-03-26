//
//  ReviewItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

// MARK: - Review
struct Review: Hashable {
    let id: String
    var reviews: [ReviewItem]?
    let ratingAverage: Double?
    let ratingCount, reviewCount: Int?
    
    init(id: String, reviews: [ReviewItem]?, ratingAverage: Double?, ratingCount: Int?, reviewCount: Int?) {
        self.id = id
        self.reviews = reviews
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.reviewCount = reviewCount
    }
}

// MARK: - ReviewItem
struct ReviewItem: Hashable {
    let username, photo, accountId: String
    let medias: [ReviewMedia]?
    let isAnonymous: Bool
    let review: String?
    let rating, createAt: Int
    let urlBadge: String?
    let isShowBadge: Bool?
    
    init(username: String, photo: String, accountId: String, medias: [ReviewMedia]?, isAnonymous: Bool, review: String?, rating: Int, createAt: Int, urlBadge: String?, isShowBadge: Bool) {
        self.username = username
        self.photo = photo
        self.accountId = accountId
        self.medias = medias
        self.isAnonymous = isAnonymous
        self.review = review
        self.rating = rating
        self.createAt = createAt
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
    }
}
