//
//  ChannelContentPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 27/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class ChannelContentPresenter: BaseFeedPresenter {

    var channelId: String = ""
    var selectedFeedId: String? = nil
    var isFollow: Bool = false

    func getNetworkFeed() {
        _loadingState.accept(true)
        if getToken()?.isEmpty == nil {
            usecase.getByPublicChannelId(page: requestedPage)
                .subscribeOn(self.concurrentBackground)
                .observeOn(MainScheduler.instance)
                .subscribe{ [weak self] result in
                    guard let self = self else { return }
                    self._loadingState.accept(false)
                    //TODO : SHOULD BE ENUM
                    if (result.code == "1000") {
                        guard let feed = result.data?.content else { return }
                        self.counterFeed = feed.count
                        
                        if self.requestedPage == 0 {
                            self.feedsDataSource.accept(feed)
                        }
                        else {
                            self.feedsDataSource.accept(self.feedsDataSource.value + feed)
                        }
                        self.requestedPage += 1
                    }
                } onError: { err in
                    self._errorMessage.accept(err.localizedDescription)
                } onCompleted: {
                }.disposed(by: disposeBag)
        } else {
            usecase.getFeedByChannelNetwork(id: channelId, page: requestedPage)
                .subscribeOn(self.concurrentBackground)
                .observeOn(MainScheduler.instance)
                .subscribe{ result in
                    self._loadingState.accept(false)
                    //TODO : SHOULD BE ENUM
                    if (result.code == "1000") {
                        guard let feed = result.data?.content else { return }
                        self.counterFeed = feed.count
                        
                        if self.requestedPage == 0 {
                            self.feedsDataSource.accept(feed)
                        }
                        else {
                            self.feedsDataSource.accept(self.feedsDataSource.value + feed)
                        }
                        self.requestedPage += 1
                    }
                } onError: { err in
                    self._errorMessage.accept(err.localizedDescription)
                } onCompleted: {
                }.disposed(by: disposeBag)
        }
    }

    func deleteFeeds(page:Int) {
        //        usecase
    }

    func updateFeedLike(likes: Int, index: Int) {
        var feed = self.feedsDataSource.value[index]
        feed.likes = (feed.likes ?? 0) + likes
    }
}
