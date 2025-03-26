//
//  RemoteCreateUserNotificationDecorator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class RemoteCreateUserNotificationDecorator: CreateUser {
    private let decoratee: CreateUser
    private let pushNotification: PushNotificationRegister
    public typealias Result = CreateUser.Result
    
    init(decoratee: CreateUser, pushNotification: PushNotificationRegister) {
        self.decoratee = decoratee
        self.pushNotification = pushNotification
    }
        
    func create(request: CreateUserRequest, completion: @escaping (Result) -> Void) {
        decoratee.create(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.pushNotification.register(request: PushNotificationRegisterRequest(accountlID: item.accountId))
                completion(.success(item))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
