//
//  FeedRepository.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 17/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

protocol FeedRepository {
    func likeFeedRemote(feed: Feed) -> Observable<DefaultResponse>
    func getFeedNetwork(page: Int) -> Observable<FeedArray>
    func getFeedByChannelNetwork(id: String, page: Int) -> Observable<FeedArray>
    func getTiktokNetwork(page: Int, size: Int, country: CleepsCountry) -> Observable<FeedArray>
    func getFeedNetworkByUserId(userId: String, page: Int) -> Observable<FeedArray>
    func getFeedNetworkByUserIdWithSize(userId: String, page: Int, size: Int) -> Observable<FeedArray>
    func getLatestFeedNetwork(userId: String) -> Observable<FeedArray>
    func deleteFeedByIdRemote(id: String) -> Observable<DeleteResponse>
    func deleteStory(_ idStories: String, _ idFeeds: String) -> Observable<DeleteResponse>
    func getByPublicChannelId(page: Int) -> Observable<FeedArray>
    func updateFeedAlreadySeen(feedId: String) -> Observable<DefaultResponse>
    func getFeedTiktok(page: Int, size: Int, direction: String) -> Observable<FeedArray>
}

final class FeedRepositoryImpl: FeedRepository {
    
    typealias FeedInstance = (RxFeedNetworkModel, String?) -> FeedRepository

    fileprivate let remote: RxFeedNetworkModel

    private let token: String?
    
    private init(remote: RxFeedNetworkModel, token: String? = nil) {
        self.remote = remote
        self.token = token
    }

    static let sharedInstance: FeedInstance = {  remoteRepo, token in
        return FeedRepositoryImpl(remote: remoteRepo, token: token)
    }
    
    func getFeedTiktok(page: Int, size: Int, direction: String) -> Observable<FeedArray> {
        return self.remote.fetchFeedTikTok(page: page, size: size, direction: direction)
    }
    
    func deleteFeedByIdRemote(id: String) -> Observable<DeleteResponse> {
        return self.remote.deleteFeedById(id: id)
    }

    func deleteStory(_ idStories: String, _ idFeeds: String) -> Observable<DeleteResponse> {
        return self.remote.deleteStoryById(idStories: idStories, idFeeds: idFeeds)
    }
    
    func updateFeedAlreadySeen(feedId: String) -> Observable<DefaultResponse> {
        return self.remote.updateFeedAlreadySeen(feedId: feedId)
    }
    
    func getByPublicChannelId(page: Int) -> Observable<FeedArray> {
        return self.remote.fetchByChannelId(id: "page", page: page)
    }


    func getFeedByChannelNetwork(id: String, page: Int) -> Observable<FeedArray> {
        return self.remote.fetchByChannelId(id: id, page: page)
    }
    
    func getTiktokNetwork(page: Int, size: Int, country: CleepsCountry) -> Observable<FeedArray> {
        return self.remote.fetchTikTok(page: page, size: size, country: country)
    }

    func likeFeedRemote(feed: Feed) -> Observable<DefaultResponse> {
        return self.remote.patchLike(feedId: feed.id ?? "", status: (feed.isLike ?? false ) ? "like" : "unlike")
    }

    func getFeedNetwork(page: Int) -> Observable<FeedArray> {
        if token != nil {
            return self.remote.fetchHomes(page: page)
        } else {
            return self.remote.fetchHomesAsGuest(page: page)
        }
    }

    func getFeedNetworkByUserId(userId: String, page: Int) -> Observable<FeedArray> {
        return remote.fetchByAccountId(id: userId, page: page)
    }
    
    func getFeedNetworkByUserIdWithSize(userId: String, page: Int, size: Int) -> Observable<FeedArray> {
        return remote.fetchByAccountIdWithSize(id: userId, page: page, size: size)
    }
    
    func getLatestFeedNetwork(userId: String) -> Observable<FeedArray> {
        return remote.fetchLatest(id: userId)
    }
}
