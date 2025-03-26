//
//  CreateGroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendbirdChatSDK

open class CreateGroupChannelUseCase {
    
    private let users: [User]
    
    public init(users: [User] = []) {
        self.users = users
    }
    
    open func createGroupChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<GroupChannel, SBError>) -> Void) {
        let params = GroupChannelCreateParams()
        
        params.coverImage = imageData
        params.addUsers(users)
        params.name = channelName
        
        if let operatorUserId = SendbirdChat.getCurrentUser()?.userId {
            params.operatorUserIds = [operatorUserId]
        }
        
        GroupChannel.createChannel(params: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
    open func createGroupChannel(name: String? = nil, coverImage: Data? = nil, selectedUserId: String, completion: @escaping ((Swift.Result<GroupChannel?, SBError>) -> Void)) {
        let channelURL = [SendbirdChat.getCurrentUser()?.userId ?? "", selectedUserId].sorted().joined(separator: "_")
        
        let params = GroupChannelCreateParams()
        params.channelURL = channelURL
        params.name = name ?? [SendbirdChat.getCurrentUser()?.userId ?? "", selectedUserId].sorted().joined(separator: "_")
        params.coverImage = coverImage
        params.isDistinct = true
        params.userIds = [SendbirdChat.getCurrentUser()?.userId ?? "", selectedUserId]

        GroupChannel.createChannel(params: params) { channel, error in
            
            if let error = error {
                if error.code == 400202 {
                    self.getGroupChannel(with: channelURL, completion: completion)
                    return
                }
                
                completion(.failure(error))
                return
            }
            
            completion(.success(channel))
        }
    }
    
    open func createGroupChannel(name: String? = nil, coverImage: Data? = nil, userId: String, selectedUserId: String, completion: @escaping ((Swift.Result<GroupChannel?, SBError>) -> Void)) {
        let channelURL =  userId + "_" + selectedUserId
        
        let params = GroupChannelCreateParams()
        params.channelURL = channelURL
        params.name = name ?? channelURL
        params.coverImage = coverImage
        params.isDistinct = true
        params.userIds = [userId, selectedUserId]

        GroupChannel.createChannel(params: params) { channel, error in
            
            if let error = error {
                if error.code == 400202 {
                    self.getGroupChannel(with: channelURL, completion: completion)
                    return
                }
                
                completion(.failure(error))
                return
            }
            
            completion(.success(channel))
        }
    }
    private func getGroupChannel(with channelURL: String, completion: @escaping ((Swift.Result<GroupChannel?, SBError>) -> Void)) {
        GroupChannel.getChannel(url: channelURL) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(channel))
        }
    }
}
