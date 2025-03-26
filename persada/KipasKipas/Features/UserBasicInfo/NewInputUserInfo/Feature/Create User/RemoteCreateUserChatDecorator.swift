//
//  RemoteCreateUserChatDecorator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class RemoteCreateUserChatDecorator: CreateUser {
    private let decoratee: CreateUser
    private let chat: SendbirdChatRegister
    public typealias Result = CreateUser.Result
    
    init(decoratee: CreateUser, chat: SendbirdChatRegister) {
        self.decoratee = decoratee
        self.chat = chat
    }
        
    func create(request: CreateUserRequest, completion: @escaping (Result) -> Void) {
        decoratee.create(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.chat.register(request: ChatRegisterRequest(accountlID: item.accountId, username: item.userName, avatar: request.photo))
                completion(.success(item))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
