//
//  StoryFeed.swift
//  KipasKipasStory
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import Foundation

public struct StoryFeed: Codable, Equatable, Hashable {
    public let id: String?
    public let typePost: String?
    public let stories: [StoryItem]?
    public let accountId: String?
    public let createAt: Int?
    public let likes: Int?
    public let comments: Int?
    public let account: StoryAccount?
    public let isLike: Bool?
    public let isFollow: Bool?
    public let totalView: Int?
    public let isBadgeActive: Bool?
    
    public init(id: String?, typePost: String?, stories: [StoryItem]?, accountId: String?, createAt: Int?, likes: Int?, comments: Int?, account: StoryAccount?, isLike: Bool?, isFollow: Bool?, totalView: Int?, isBadgeActive: Bool?) {
        self.id = id
        self.typePost = typePost
        self.stories = stories
        self.accountId = accountId
        self.createAt = createAt
        self.likes = likes
        self.comments = comments
        self.account = account
        self.isLike = isLike
        self.isFollow = isFollow
        self.totalView = totalView
        self.isBadgeActive = isBadgeActive
    }
    
    public static func ==(lhs: StoryFeed, rhs: StoryFeed) -> Bool {
        return lhs.id == rhs.id && lhs.accountId == rhs.accountId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
