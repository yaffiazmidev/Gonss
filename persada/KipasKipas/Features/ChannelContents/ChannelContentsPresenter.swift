//
//  ChannelContentsPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol IChannelContentsPresenter {
    typealias ChannelContentsResult<T> = Swift.Result<T, DataTransferError>
    
    func presentContents(with result: ChannelContentsResult<FeedArray>)
    func presentChannelDetail(with result: ChannelContentsResult<ChannelDetail>)
    func presentFollowChannel(with result: ChannelContentsResult<DefaultEntity>)
    func presentUnfollowChannel(with result: ChannelContentsResult<DefaultEntity>)
}

class ChannelContentsPresenter: IChannelContentsPresenter {

    weak var controller: IChannelContentsViewController?

    init(controller: IChannelContentsViewController) {
        self.controller = controller
    }

    func presentContents(with response: FeedArray?) {
        controller?.displayContents(feeds: response?.data?.content ?? [])
    }
    
    func presentChannelDetail(response: ChannelDetail?) {
        controller?.displayChannelDetail(channel: response?.data)
    }
    
    func presentContents(with result: ChannelContentsResult<FeedArray>) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            controller?.displayContents(feeds: response.data?.content ?? [])
        }
    }
    
    func presentChannelDetail(with result: ChannelContentsResult<ChannelDetail>) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            controller?.displayChannelDetail(channel: response.data)
        }
    }
    
    func presentFollowChannel(with result: ChannelContentsResult<DefaultEntity>) {
        switch result {
        case .failure(_):
            controller?.displayFollowStatus(isSuccess: false)
        case .success(_):
            controller?.displayFollowStatus(isSuccess: true)
        }
    }
    
    func presentUnfollowChannel(with result: ChannelContentsResult<DefaultEntity>) {
        switch result {
        case .failure(_):
            controller?.displayUnfollowStatus(isSuccess: false)
        case .success(_):
            controller?.displayUnfollowStatus(isSuccess: true)
        }
    }
}
