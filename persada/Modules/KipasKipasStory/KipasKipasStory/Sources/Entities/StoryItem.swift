//
//  StoryItem.swift
//  KipasKipasStory
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import Foundation

public struct StoryItem: Codable, Equatable {
    public let id: String
    public let feedId: String
    public let feedIdRepost: String?
    public let usernameRepost: String?
    public let firstSeenAccountId: String?
    public let firstSeenPhoto: String?
    public let secondSeenAccountId: String?
    public let secondSeenPhoto: String?
    public let totalView: Int
    public let storyType: String?
    public let medias: [StoryMediaItem]
    public let createAt: Int
//    public let products: [Double]? // ini isinya list product, belum kepake. jadi di deactive dulu
    public let isHasView: Bool
    public let isLike: Bool?
    
    public init(id: String, feedId: String, feedIdRepost: String?, usernameRepost: String?, firstSeenAccountId: String?, firstSeenPhoto: String?, secondSeenAccountId: String?, secondSeenPhoto: String?, totalView: Int, storyType: String?, medias: [StoryMediaItem], createAt: Int, isHasView: Bool, isLike: Bool?) {
        self.id = id
        self.feedId = feedId
        self.feedIdRepost = feedIdRepost
        self.usernameRepost = usernameRepost
        self.firstSeenAccountId = firstSeenAccountId
        self.firstSeenPhoto = firstSeenPhoto
        self.secondSeenAccountId = secondSeenAccountId
        self.secondSeenPhoto = secondSeenPhoto
        self.totalView = totalView
        self.storyType = storyType
        self.medias = medias
        self.createAt = createAt
        self.isHasView = isHasView
        self.isLike = isLike
    }
    
    public static func ==(lhs: StoryItem, rhs: StoryItem) -> Bool {
        return lhs.feedId == rhs.feedId
    }
}
