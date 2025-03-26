//
//  ChannelListPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/03/22.
//

import UIKit

protocol IChannelListPresenter {
    func presentChannels(with result: ChannelsLoader.Result)
    func presentChannelsFollowing(with result: ChannelsFollowingLoader.Result)
}

class ChannelListPresenter: IChannelListPresenter {
    
	weak var controller: IChannelListViewController!
	
	init(controller: IChannelListViewController) {
		self.controller = controller
	}
    
    func presentChannels(with result: ChannelsLoader.Result) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            controller.displayChannels(contents: response.contents ?? [])
        }
    }
    
    func presentChannelsFollowing(with result: ChannelsFollowingLoader.Result) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
        case .success(let response):
            let channels = response.contents?.compactMap( {
                ChannelsItemContent(
                    code: $0.code,
                    name: $0.name,
                    id: $0.id,
                    createAt: $0.createAt,
                    photo: $0.photo,
                    description: $0.description,
                    isFollow: $0.isFollow)
            })
            
            controller.displayChannels(contents: channels ?? [])
        }
    }
}
