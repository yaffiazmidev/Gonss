//
//  HotnewsLoader.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 02/01/24.
//

import Foundation

public protocol HotnewsLoader {
    func getFeedVideo(with request: PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<RemoteFeedItemData, Error>) -> Void)
    func getUserProfile(byId profileId: String, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void)
    func getUserProfile(byUsername username: String, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void)
    func followUser(byId userId: String, completion: @escaping (Error?) -> Void)
    func likePost(byId id: String, isLiking: Bool, completion: @escaping (Error?) -> Void)
    func seenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void)
    func guestSeenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void)
    func getFeed(byId id: String,isLogin:Bool, completion: @escaping (Swift.Result<RemoteFeedItemContent, Error>) -> Void)
    func getFollowingSuggest(page: Int, size: Int, completion: @escaping (Swift.Result<RemoteFollowingSuggestData, Error>) -> Void)
}

public struct PagedFeedVideoLoaderRequest: Equatable {
    public let page: Int
    public let isTrending: Bool?
    public let size: Int
    public let categoryId: String?
    public let isVodAvailable: Bool?
    public let provinceId: String?
    public let longitude: Double?
    public let latitude: Double?
    public let country: Country
    public let isPublic: Bool
    public let feedType: FeedType
    public let profileId: String
    public let deviceId: String?
    public let channelId: String
    public let mediaType: FeedMediaType?
    public let searchKeyword: String?

    public init(
        page: Int,
        isTrending: Bool? = nil,
        size: Int = 10,
        categoryId: String? = nil,
        isVodAvailable: Bool? = nil,
        provinceId: String? = nil,
        longitude: Double? = nil,
        latitude: Double? = nil,
        country: Country = .indo,
        isPublic: Bool,
        feedType: FeedType,
        profileId: String = "",
        deviceId: String? = nil,
        mediaType: FeedMediaType? = nil,
        channelId: String = "",
        searchKeyword: String? = ""
    ) {
        self.page = page
        self.isTrending = isTrending
        self.size = size
        self.categoryId = categoryId
        self.isVodAvailable = isVodAvailable
        self.provinceId = provinceId
        self.longitude = longitude
        self.latitude = latitude
        self.country = country
        self.isPublic = isPublic
        self.feedType = feedType
        self.profileId = profileId
        self.deviceId = deviceId
        self.mediaType = mediaType
        self.channelId = channelId
        self.searchKeyword = searchKeyword
    }
}

public extension PagedFeedVideoLoaderRequest {
    enum Country: String {
        case indo = "tiktok"
        case china = "chinatiktok"
        case korea = "koreacleeps"
        case thailand = "thailandcleeps"
    }

    var path: String {
        switch feedType {
        case .donation:
            return "/feeds/post/donation"

        case .hotNews:
            return "/feeds/channels"

        case .feed:
            return "/feeds/post/home"

        case .profile:
            return "/profile/post/\(profileId)"
        case .following:
            return "/feeds/following"
        case .explore:
            return "/channels/general/posts"
        case .channel:
            return "/feeds/channel/\(channelId)"
        case .searchTop:
            return "/search/top"
        default:
            return ""
        }
    }
}
