//
//  ChannelListInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/03/22.
//

import UIKit

protocol IChannelListInteractor: AnyObject {
    var page: Int { get set }
    var totalPages: Int { get set }
    var isFollowing: Bool { get set }
    
    func fetchChannels()
    func loadMoreChannels()
}

class ChannelListInteractor: IChannelListInteractor {
    
    var page: Int = 0
    var totalPages: Int = 0
    var isFollowing: Bool = false
    
    let presenter: IChannelListPresenter
    let channelsLoader: ChannelsLoader
    let channelsFollowingLoader: ChannelsFollowingLoader
    
    init(presenter: IChannelListPresenter,
         channelsLoader: ChannelsLoader,
         channelsFollowingLoader: ChannelsFollowingLoader)
    {
        self.presenter = presenter
        self.channelsLoader = channelsLoader
        self.channelsFollowingLoader = channelsFollowingLoader
    }
    
    func fetchChannels() {
        isFollowing ? fetchFollowingChannel() : fetchAllChannel()
    }
    
    func loadMoreChannels() {
        page += 1
        fetchChannels()
    }
}

extension ChannelListInteractor {
    
    private func fetchAllChannel() {
        let request = ChannelsRequest(page: page, isPublic: !AUTH.isLogin())
        channelsLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentChannels(with: result)
            
            if case .success(let response) = result {
                self.totalPages = response.totalPages - 1
            }
        }
    }
    
    private func fetchFollowingChannel() {
        let request = ChannelsFollowingRequest(page: page)
        channelsFollowingLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentChannelsFollowing(with: result)
            
            if case .success(let response) = result {
                self.totalPages = response.totalPages - 1
            }
        }
    }
}
