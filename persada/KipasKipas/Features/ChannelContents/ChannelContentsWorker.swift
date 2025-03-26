//
//  ChannelContentsWorker.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol IChannelContentsWorker: AnyObject {
    typealias CompletionHandler<T> = (Swift.Result<T, DataTransferError>) -> Void
    
    func getChannel(with id: String, completion: @escaping CompletionHandler<ChannelDetail>)
    func followChannel(with id: String, completion: @escaping CompletionHandler<DefaultEntity>)
    func unfollowChannel(with id: String, completion: @escaping CompletionHandler<DefaultEntity>)
    func getChannelContents(with id: String, page: Int, completion: @escaping CompletionHandler<FeedArray>)
}

public final class ChannelContentsWorker: IChannelContentsWorker {
    private let network: DataTransferService
    
    init(network: DataTransferService) {
        self.network = network
    }
    
    func getChannel(with id: String, completion: @escaping CompletionHandler<ChannelDetail>) {
        let endpoint = Endpoint<ChannelDetail>(with: ChannelAPIEndpoint.channel(id: id))
        network.request(with: endpoint, completion: completion)
    }
    
    func followChannel(with id: String, completion: @escaping CompletionHandler<DefaultEntity>) {
        let endpoint = Endpoint<DefaultEntity>(with: ChannelAPIEndpoint.followChannel(id: id))
        network.request(with: endpoint, completion: completion)
    }
    
    func unfollowChannel(with id: String, completion: @escaping CompletionHandler<DefaultEntity>) {
        let endpoint = Endpoint<DefaultEntity>(with: ChannelAPIEndpoint.unfollowChannel(id: id))
        network.request(with: endpoint, completion: completion)
    }
    
    func getChannelContents(with id: String, page: Int, completion: @escaping CompletionHandler<FeedArray>) {
        let endpoint = Endpoint<FeedArray>(with: FeedAPIEndpoint.getChannelContentsBy(id: id, page: page))
        network.request(with: endpoint, completion: completion)
    }
}
