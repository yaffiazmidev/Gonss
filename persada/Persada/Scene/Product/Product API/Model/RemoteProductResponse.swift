//
//  RemoteProductResponse.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - Pageable
struct RemoteProductPageable: Codable {
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
struct RemoteProductSort: Codable {
    let unsorted, sorted, empty: Bool?
}
