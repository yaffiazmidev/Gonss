//
//  RemoteFollowingSuggest.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/02/24.
//

import Foundation

struct RemoteFollowingSuggest: Codable {
    let data: RemoteFollowingSuggestData?
    let code: String?
    let message: String?
}

public struct RemoteFollowingSuggestData: Codable {
    let content: [RemoteFollowingSuggestItem]?
    let last: Bool?
    let totalPages: Int?
    let totalElements: Int?
    let size: Int?
    let number: Int?
    let first: Bool?
    let numberOfElements: Int?
    let empty: Bool?
}
