//
//  RemoteFollowingSuggestion.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation

public struct RemoteFollowingSuggestion: Codable {
    let code, message: String?
    let data: RemoteFollowingSuggestionData?
}

public struct RemoteFollowingSuggestionData: Codable {
    let content: [RemoteFollowingSuggestionContent]?
    var totalPages: Int?
    let last: Bool?
}

public struct RemoteFollowingSuggestionContent: Codable {
    let account: RemoteFollowingSuggestionAccount?
    let feeds: [Feed]?
}

public struct RemoteFollowingSuggestionAccount: Codable {
    let id: String?
    let username: String?
    let name: String?
    let photo: String?
    let isFollow: Bool?
    let isVerified: Bool?
}

public struct RemoteFollowingSuggestionFeed: Codable {
    let post: RemoteFollowingSuggestionPost?
}

public struct RemoteFollowingSuggestionPost: Codable {
    let id: String?
    let medias: [RemoteFollowingSuggestionMedia]?
}

public struct RemoteFollowingSuggestionMedia: Codable {
    let id: String?
    let url: String?
}
