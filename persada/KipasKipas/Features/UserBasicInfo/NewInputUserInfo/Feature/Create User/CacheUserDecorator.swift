//
//  CacheUserDecorator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class CacheUserDecorator: CreateUser {
    private let decoratee: CreateUser
    private let store: UserStore
    public typealias Result = CreateUser.Result
    
    init(decoratee: CreateUser, store: UserStore) {
        self.decoratee = decoratee
        self.store = store
    }
        
    func create(request: CreateUserRequest, completion: @escaping (Result) -> Void) {
        decoratee.create(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.store.insert(item.toLocal()) { _ in }
                completion(.success(item))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension UserItem {
    func toLocal() -> LocalUserItem {
        return LocalUserItem(accessToken: accessToken, refreshToken: refreshToken, expiresIn: String(expiresIn), role: role, userName: userName, userEmail: userEmail, userMobile: userMobile, accountId: accountId)
    }
}
