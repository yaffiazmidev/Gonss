//
//  BaseFeedPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 19/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


// NOTE KALAU SEMUA UDAH DI GANTI KE RX, INI GA DIPAKE
protocol FeedPresentationLogic {
	func presentResponse(_ response: FeedModel.Response)
}

open class BaseFeedPresenter: BasePresenter {
	weak var viewController: NewSelebDisplayLogic?
	let disposeBag = DisposeBag()
	let usecase: FeedUseCase
	var expandedRow:[Int] = []
    var currentMultipleIndex: [Int: Int] = [:]
    let cache = FeedSimpleCache.instance

	var lastPage: Int = 0
	var requestedPage: Int = 0
	var counterFeed: Int = 0
	var isDataEmpty: Bool = false
	var indexFeed: Int = 0
	var idFeed: String = ""

	let _loadingState = BehaviorRelay<Bool>(value: false)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}

	var feeds: Driver<[Feed]>? = nil

	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

	let feedsDataSource: BehaviorRelay<[Feed]> = BehaviorRelay<[Feed]>(value: [])



  init(_ viewController: NewSelebDisplayLogic?) {
		self.viewController = viewController
		self.usecase = Injection.init().provideFeedUseCase()
	}

	func updateFeedComment(comments: Int, index: Int) {
		var feed = self.feedsDataSource.value[index]
		feed.comments = (feed.comments ?? 0) + comments
	}

	func updateFeedLikes(likes: Int, index: Int) {
		var feed = self.feedsDataSource.value[index]
		feed.likes = (feed.likes ?? 0) + likes
	}
	
	func updateFeedLikesFromDetail(feed: Feed, index: Int) {
		var feedIn = self.feedsDataSource.value[index]
		feedIn.likes = feed.likes
		feedIn.isLike = feed.isLike
	}

	func saveFeed(feed: Feed) {
		usecase.likeFeed(feed: feed)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ [weak self] result in
                guard self != nil else { return }
				print(result)
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	func likeFeedRemote(feed: Feed, index: Int) {
		var feedIn = self.feedsDataSource.value
		feedIn[index].likes = feed.likes
		feedIn[index].isLike = feed.isLike
        
        // click like/unlike video not restart
        self.feedsDataSource.accept(feedIn)
        
		usecase.likeFeedRemote(feed: feed)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ [weak self] result in
                guard self != nil else { return }
				print(result)
                NotificationCenter.default.post(name: .handleUpdateExploreContent, object: nil)
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}

    func deleteFeedById(id: String, successDelete: @escaping () -> ()) {
		_loadingState.accept(true)
		usecase.deleteFeedById(id: id)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ [weak self] result in
                guard let self = self else { return }
                self._loadingState.accept(false)
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
                self._loadingState.accept(false)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
    
    func updateFeedAlreadySeen(feedId: String, isSuccessUpdate: @escaping (Bool) -> ()) {
        usecase.updateFeedAlreadySeen(feedId: feedId)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ [weak self] result in
                guard self != nil else { return }
                if (result.code == "1000") {
                    isSuccessUpdate(true)
                    return
                }
                isSuccessUpdate(false)
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
                isSuccessUpdate(false)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}
