//
//  ProfileDetailPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 08/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Combine

let scrollToNotifKey = Notification.Name(rawValue: "scrollToNotifKey")

class ProfileDetailPresenter: BaseFeedPresenter {

	var selectedCommentIndex: Int = 0
	var selectedFeed: Feed?
	let userId: String
    var size: Int = 0
    var totalPage: Int = 0
	let hashtagUseCase = Injection.init().provideHashtagUseCase()
	private let profileNetwork = ProfileNetworkModel() // solusi sementara
    
	init(userId: String) {
		self.userId = userId
		super.init(nil)
	}

    func getNetworkFeed() {
        _loadingState.accept(true)
        usecase.getFeedNetworkByUserId(userId: userId, page: requestedPage)
            .subscribeOn(self.concurrentBackground).observeOn(MainScheduler.instance).subscribe{ [weak self] result in
            guard let self = self else { return }
            
            guard let statusCode = result.code, statusCode == "1000" else {
                self._errorMessage.accept("Data not found!")
                return
            }
            
            if self.requestedPage == 0 {
                self.feedsDataSource.accept(result.data?.content ?? [])
            } else {
                let newFeed = result.data?.content ?? []
                self.feedsDataSource.accept(self.feedsDataSource.value + newFeed)
            }
                
            self.totalPage = result.data?.totalPages ?? 0
            
        } onError: { err in
            self._loadingState.accept(false)
            self._errorMessage.accept(err.localizedDescription)
        } onCompleted: {
        }.disposed(by: disposeBag)
    }
    
	
	func getHashtagFeed() -> Driver<[Feed]>{
		_loadingState.accept(true)
		
        return hashtagUseCase.getHashtagList(hashtag: userId, page: requestedPage, size: 10)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.map({ feed in
                self._loadingState.accept(false)
				self.feedsDataSource.accept(feed.data?.content ?? [])
				self.counterFeed = feed.data?.content?.count ?? 0

				return feed.data?.content ?? []
			})
			.asDriver { error in
                self._loadingState.accept(false)
				return Driver.empty()
			}
//		hashtagUseCase.getHashtagList(hashtag: userId, page: requestedPage)
//			.subscribeOn(concurrentBackground)
//			.observeOn(MainScheduler.init())
//			.subscribe { (result) in
//				if (result.code == "1000") {
//					if let feeds = result.data?.content {
//
//						self.feedsDataSource.accept(feeds)
//						self.counterFeed = self.feedsDataSource.value.count
//						self.saveFeeds(feedNetwork: feeds, page: self.requestedPage)
//					}
//				}
//			} onError: { [weak self] (err) in
//				self?._errorMessage.accept(err.localizedDescription)
//			}.disposed(by: disposeBag)
	}
	
	func getNetworkHashtagFeed() {
		hashtagUseCase.getHashtagList(hashtag: userId, page: requestedPage, size: 10)
			.subscribeOn(concurrentBackground)
			.observeOn(MainScheduler.init())
			.subscribe { (result) in
				if (result.code == "1000") {
					if let feeds = result.data?.content {

						self.feedsDataSource.accept(feeds)
						self.counterFeed = self.feedsDataSource.value.count
					}
				}
			} onError: { [weak self] (err) in
				self?._errorMessage.accept(err.localizedDescription)
			}.disposed(by: disposeBag)
	}

	func updateLikeFeed(_ feed: Feed) {
		_loadingState.accept(true)
		usecase.likeFeed(feed: feed)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ result in
				//TODO : SHOULD BE ENUM
				if (result.code == "1000") {
					self._loadingState.accept(false)
				}
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	func detail(_ text: String) -> AnyPublisher<ProfileResult, Error> {
		return profileNetwork.profileUsername(.profileUsername(text: text))
	}
}
