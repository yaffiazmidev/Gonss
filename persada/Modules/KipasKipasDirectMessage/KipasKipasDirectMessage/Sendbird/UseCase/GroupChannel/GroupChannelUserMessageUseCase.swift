//
//  GroupChannelInputUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChatSDK

open class GroupChannelUserMessageUseCase {
    
    public let channel: GroupChannel
    
    public init(channel: GroupChannel) {
        self.channel = channel
    }
    
    open func sendMessage(_ message: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) -> UserMessage? {
        return channel.sendUserMessage(message) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func sendMessage(params: UserMessageCreateParams, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let message = channel.sendUserMessage(params: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else {
                return completion(.failure(SBError(domain: "Message is empty..", code: 404)))
            }
            
            completion(.success(message))
        }
        
        completion(.success(message))
    }
    
    open func sendMessage(with value: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let message = channel.sendUserMessage(value) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else {
                return completion(.failure(SBError(domain: "Message is empty..", code: 404)))
            }
            
            completion(.success(message))
        }
        
        completion(.success(message))
    }
    
    open func resendMessage(_ message: UserMessage, completion: @escaping (Result<BaseMessage, SBError>) -> Void) {
        channel.resendUserMessage(message) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func updateMessage(_ message: UserMessage, to newMessage: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let params = UserMessageUpdateParams(message: newMessage)
        
        channel.updateUserMessage(messageId: message.messageId, params: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func deleteMessage(_ message: BaseMessage, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.deleteMessage(message) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
}
