//
//  FollowArtistArray.swift
//  Persada
//
//  Created by Muhammad Noor on 28/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - FollowArtistArray
struct FollowArtistArray: Codable {
    let code, message: String?
    let data: FollowArtist?
}

// MARK: - FollowArtist
struct FollowArtist: Codable {
    let content: [ContentArtist]?
    let pageable: Pageable?
    let totalPages, totalElements: Int?
    let last: Bool?
    let sort: Sort?
    let numberOfElements: Int?
    let first: Bool?
    let size, number: Int?
    let empty: Bool?
}

// MARK: - ContentArtist
struct ContentArtist: Codable {
    let id, username, name: String?
    let photo: String?
    let isVerified: Bool?
}
