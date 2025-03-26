//
//  FeedCleepsEndpointRequest.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 27/12/22.
//

import Foundation

public struct GetFeedEndpointRequest {
    public let isPublic: Bool
    public let page: Int
    
    public init(isPublic: Bool, page: Int) {
        self.isPublic = isPublic
        self.page = page
    }
}

public struct GetCleepsEndpointRequest {
    public let page: Int
    public let country: CleepsCountry
    public let isTrending: Bool
    
    public init(page: Int, country: CleepsCountry, isTrending: Bool) {
        self.page = page
        self.country = country
        self.isTrending = isTrending
    }
}

public struct GetProfileEndpointRequest {
    public let page: Int
    public let userID: String
    
    public init(page: Int, userID: String) {
        self.page = page
        self.userID = userID
    }
}

public struct GetTrendingEndpointRequest {
    public let page: Int
    
    public init(page: Int) {
        self.page = page
    }
}

public struct GetHashtagEndpointRequest {
    public let page: Int
    public let hashtag: String
    
    public init(page: Int, hashtag: String) {
        self.page = page
        self.hashtag = hashtag
    }
}

public struct GetExploreEndpointRequest {
    public let isPublic: Bool
    public let page: Int
    
    public init(isPublic: Bool, page: Int) {
        self.isPublic = isPublic
        self.page = page
    }
}

public struct GetFeedChannelEndpointRequest {
    public let isPublic: Bool
    public let page: Int
    public let channelId: String
    
    public init(isPublic: Bool, page: Int, channelId: String) {
        self.isPublic = isPublic
        self.page = page
        self.channelId = channelId
    }
}

public struct GetFeedSearchEndpointRequest {
    public let isPublic: Bool
    public let page: Int
    public let searchText: String
    
    public init(isPublic: Bool, page: Int, searchText: String) {
        self.isPublic = isPublic
        self.page = page
        self.searchText = searchText
    }
}

public struct GetFollowingEndpointRequest {
    public let isPublic: Bool
    public let page: Int
    public let searchText: String
    
    public init(isPublic: Bool, page: Int, searchText: String) {
        self.isPublic = isPublic
        self.page = page
        self.searchText = searchText
    }
}
