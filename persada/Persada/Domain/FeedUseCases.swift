//
//  FeedUseCases.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

// todo: nantinya pakai ini buat gantiin interactor supaya tidak terjadi pengulangan kode di setiap scene (pemanggilan interactor yang sama)

import Foundation
import RxSwift

protocol FeedUseCase {
    func getFeedNetwork(page: Int) -> Observable<FeedArray>
    func likeFeed(feed: Feed) -> Observable<DefaultResponse>
		func likeFeedRemote(feed: Feed) -> Observable<DefaultResponse>
    func getFeedByChannelNetwork(id: String, page: Int) -> Observable<FeedArray>
    func getTikTokNetwork(page: Int, size: Int, country: TikTokCountry) -> Observable<FeedArray>
    func getFeedNetworkByUserId(userId: String, page: Int) -> Observable<FeedArray>
	func getFeedNetworkByUserIdWithSize(userId: String, page: Int, size: Int) -> Observable<FeedArray>
    func getLatestFeedNetwork(userId: String) -> Observable<FeedArray>
    func deleteFeedById(id: String) -> Observable<DeleteResponse>
    func deleteFeedByIdRemote(id: String) -> Observable<DeleteResponse>
    func deleteStoryBy(idStories: String, idFeeds: String) -> Observable<DeleteResponse>
	func getByPublicChannelId(page: Int) -> Observable<FeedArray>
    func updateFeedAlreadySeen(feedId: String) -> Observable<DefaultResponse>
    func getFeedTiktok(page: Int, size: Int, direction: String) -> Observable<FeedArray>
}

class FeedInteractorRx: FeedUseCase {
    
    private let repository: FeedRepository

    required init(repository: FeedRepository) {
        self.repository = repository
    }
    
    func getFeedTiktok(page: Int, size: Int, direction: String) -> Observable<FeedArray> {
        return repository.getFeedTiktok(page: page, size: size, direction: direction)
    }
    
    func updateFeedAlreadySeen(feedId: String) -> Observable<DefaultResponse> {
        return repository.updateFeedAlreadySeen(feedId: feedId)
    }
    
    func getTikTokNetwork(page: Int, size: Int, country: TikTokCountry) -> Observable<FeedArray> {
        return repository.getTiktokNetwork(page: page, size: size, country: country)
    }

    func getFeedByChannelNetwork(id: String, page: Int) -> Observable<FeedArray> {
        repository.getFeedByChannelNetwork(id: id, page: page)
    }

    func deleteFeedById(id: String) -> Observable<DeleteResponse> {
        return repository.deleteFeedById(id)
    }
    
    func deleteFeedByIdRemote(id: String) -> Observable<DeleteResponse> {
        return repository.deleteFeedByIdRemote(id: id)
    }

    func deleteStoryBy(idStories: String, idFeeds: String) -> Observable<DeleteResponse> {
        return repository.deleteStory(idStories, idFeeds)
    }
    
    func getFeedNetwork(page: Int) -> Observable<FeedArray> {
        return repository.getFeedNetwork(page: page)
    }

    func likeFeed(feed: Feed) -> Observable<DefaultResponse> {
        return repository.likeFeed(feed: feed)
    }
	
	func likeFeedRemote(feed: Feed) -> Observable<DefaultResponse> {
		return repository.likeFeedRemote(feed: feed)
	}

    func getFeedNetworkByUserId(userId: String, page: Int) -> Observable<FeedArray> {
        return repository.getFeedNetworkByUserId(userId: userId, page: page)
    }
	
	func getFeedNetworkByUserIdWithSize(userId: String, page: Int, size: Int) -> Observable<FeedArray> {
		return repository.getFeedNetworkByUserIdWithSize(userId: userId, page: page, size: size)
	}
    
    func getLatestFeedNetwork(userId: String) -> Observable<FeedArray> {
        return repository.getLatestFeedNetwork(userId: userId)
    }

	func getByPublicChannelId(page: Int) -> Observable<FeedArray> {
		return repository.getByPublicChannelId(page: page)
	}

}
