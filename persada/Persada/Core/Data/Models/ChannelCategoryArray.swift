//
//  ChannelCategoryArray.swift
//  Persada
//
//  Created by Muhammad Noor on 27/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - ChannelCategory
struct ChannelCategoryArray: Codable {
    let code, message: String?
    let data: ChannelCategory?
}

// MARK: - ChannelCategory
struct ChannelCategory: Codable {
    let content: [Content]?
    let pageable: Pageable?
    let totalPages, totalElements: Int?
    let last: Bool?
    let sort: Sort?
    let numberOfElements: Int?
    let first: Bool?
    let size, number: Int?
    let empty: Bool?
}

// MARK: - Content
struct Content: Codable {
    let id, name: String?
    let photo: String?
}

// MARK: - Pageable
struct Pageable: Codable {
    let sort: Sort?
    let pageNumber, pageSize, offset: Int?
    let paged, unpaged: Bool?
}

// MARK: - Sort
struct Sort: Codable {
    let sorted, unsorted, empty: Bool?
    
    enum CodingKeys: String, CodingKey {
        case empty = "empty"
        case sorted = "sorted"
        case unsorted = "unsorted"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        empty = try values.decodeIfPresent(Bool.self, forKey: .empty)
        sorted = try values.decodeIfPresent(Bool.self, forKey: .sorted)
        unsorted = try values.decodeIfPresent(Bool.self, forKey: .unsorted)
    }
}

