//
//  GroupChannelSearchUseCase.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 27/07/23.
//

import Foundation
import SendbirdChatSDK

public protocol GroupChannelSearchUseCaseDelegate: AnyObject {
    func groupChannelSearchUseCase(_ groupChannelSearchUseCase: GroupChannelSearchUseCase, didUpdateChannels channels: [GroupChannel])
    func groupChannelSearchUseCase(_ groupChannelSearchUseCase: GroupChannelSearchUseCase, didReceiveError error: SBError)
}

// MARK: - GroupChannelListUseCase

open class GroupChannelSearchUseCase: NSObject {
    
    public weak var delegate: GroupChannelSearchUseCaseDelegate?
    public var channels: [GroupChannel] = []
    private var channelSearchQuery: GroupChannelListQuery?
    
    public override init() {
        super.init()
    }
    
    open func searchChannel(keyword: String, fields: SendbirdChatSDK.GroupChannelListQuerySearchField = .memberNickname) {
        channelSearchQuery = createGroupChannelListCollection(keyword: keyword, fields: fields)
        channelSearchQuery?.loadNextPage { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelSearchUseCase(self, didReceiveError: error)
                return
            }
            
            self.channels = channels ?? []
            self.delegate?.groupChannelSearchUseCase(self, didUpdateChannels: self.channels)
        }
    }
    
    open func searchChannel(keyword: String,
                            fields: SendbirdChatSDK.GroupChannelListQuerySearchField = .memberNickname,
                            completion: @escaping ((Swift.Result<[GroupChannel], Error>) -> Void)) {
        
        channelSearchQuery = createGroupChannelListCollection(keyword: keyword, fields: fields)
        channelSearchQuery?.loadNextPage { channels, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(channels ?? []))
        }
    }
        
    open func createGroupChannelListCollection(keyword: String, fields: SendbirdChatSDK.GroupChannelListQuerySearchField = .memberNickname) -> GroupChannelListQuery {
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery { params in
            params.includeEmptyChannel = false
            params.setSearchFilter(keyword, fields: fields)
        }

        return channelListQuery
    }
}
