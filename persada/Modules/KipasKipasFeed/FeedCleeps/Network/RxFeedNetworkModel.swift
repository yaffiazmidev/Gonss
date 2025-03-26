//
//  RxFeedNetworkModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

public final class RxFeedNetworkModel {
    private let network: Network<FeedArray>
    private let networkDelete: Network<DeleteResponse>
    private let networkDefault: Network<DefaultResponse>

    init(network: Network<FeedArray>, networkDefault: Network<DefaultResponse>, networkDelete: Network<DeleteResponse>) {
        self.network = network
        self.networkDefault = networkDefault
        self.networkDelete = networkDelete
    }

    func fetchHomes(page: Int) -> Observable<FeedArray> {
        return network.getItems(FeedEndpoint.home(page: page).path, parameters: FeedEndpoint.home(page: page).parameter)
    }
    
    func fetchHomesAsGuest(page: Int) -> Observable<FeedArray> {
        return network.getItems(FeedEndpoint.homeAsGuest(page: page).path, parameters: FeedEndpoint.homeAsGuest(page: page).parameter)
    }

    func patchLike(feedId: String, status: String) -> Observable<DefaultResponse> {
        let feedRequest = FeedEndpoint.rxlikeFeed(id: feedId, status: status)
        return networkDefault.updateItemWithURLParam(feedRequest.path, parameters: feedRequest.parameter, headers: feedRequest.header)
    }

    func fetchByChannelId(id: String, page: Int) -> Observable<FeedArray> {
        let request = FeedEndpoint.byChannelId(id: id, page: page)
        return network.getItems(request.path, parameters: request.parameter)
    }
    
//    func fetchByPublicChannelId(page: Int) -> Observable<FeedArray> {
//        let request = ChannelEndpoint.publicExploreChannel(page: page)
//        return network.getItems(request.path)
//    }
    
    func fetchTikTok(page: Int, size: Int, country: CleepsCountry) -> Observable<FeedArray> {
        let request = FeedEndpoint.tiktok(code: country.rawValue, page: page, size: size)
        return network.getItems(request.path, parameters: request.parameter)
    }

    func fetchByAccountId(id: String, page: Int) -> Observable<FeedArray> {
        let request = FeedEndpoint.byProfileId(id: id, page: page)
        return network.getItems(request.path, parameters: request.parameter)
    }
    
    func fetchByAccountIdWithSize(id: String, page: Int, size: Int) -> Observable<FeedArray> {
        let request = FeedEndpoint.byProfileIdWithSize(id: id, page: page, size: size)
        return network.getItems(request.path, parameters: request.parameter)
    }
    
    func fetchLatest(id: String) -> Observable<FeedArray> {
        let request = FeedEndpoint.latest(id: id)
        return network.getItems(request.path, parameters: request.parameter)
    }

    func deleteFeedById(id: String) -> Observable<DeleteResponse> {
        let request = FeedEndpoint.deletePost(id: id)
        return networkDelete.deleteItem(request.path, parameters: request.parameter, headers: request.header)
    }
    
    func deleteStoryById(idStories: String, idFeeds: String) -> Observable<DeleteResponse> {
        let request = FeedEndpoint.deleteStory(idStories: idStories, idFeeds: idFeeds)
        return networkDelete.deleteItem(request.path, parameters: request.parameter, headers: request.header)
    }
    
    func updateFeedAlreadySeen(feedId: String) -> Observable<DefaultResponse> {
        let request = FeedEndpoint.updateFeedAlreadySeen(feedId: feedId)
        return networkDefault.updateItemWithURLParam(request.path, parameters: request.parameter, headers: request.header)
    }
    
    func fetchFeedTikTok(page: Int, size: Int, direction: String) -> Observable<FeedArray> {
        let request = FeedEndpoint.feedTikTok(code: direction, page: page, size: size)
        return network.getItems(request.path, parameters: request.parameter)
    }
}
