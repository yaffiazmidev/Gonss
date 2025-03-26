//
//  RemoteReviewResponse.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

// MARK: - Pageable
struct RemoteReviewPageable: Codable {
    let offsetPage: Int?
    let sort: RemoteReviewSort?
    let startID: String?
    let nocache: Bool?
    let pageNumber, pageSize, offset: Int?
    let paged, unpaged: Bool?

    enum CodingKeys: String, CodingKey {
        case offsetPage, sort
        case startID = "startId"
        case nocache, pageNumber, pageSize, offset, paged, unpaged
    }
}

// MARK: - Sort
struct RemoteReviewSort: Codable {
    let unsorted, sorted, empty: Bool?
}
