//
//  RemoteReview.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

// MARK: - RemoteReview
struct RemoteReviewRoot: Codable {
    let code, message: String?
    let data: RemoteReview?
}

// MARK: - DataClass
struct RemoteReview: Codable {
    let id: String?
    let reviews: [RemoteReviewItem]?
    let ratingAverage: Double?
    let ratingCount, reviewCount: Int?
}

// MARK: - Review
struct RemoteReviewItem: Codable {
    let reviewId, productId, ratingId, photo: String?
    let username, accountId: String
    let medias: [RemoteReviewMedia]?
    let isAnonymous: Bool
    let review: String?
    let rating, createAt: Int
    let urlBadge: String?
    let isShowBadge: Bool?
}
