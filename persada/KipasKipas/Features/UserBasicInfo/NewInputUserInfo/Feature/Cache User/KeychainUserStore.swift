//
//  KeychainUserItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class KeychainUserStore: UserStore {
    
    private let store: KeychainStore
    
    public init(query: KeychainStoreQueryable = GenericPasswordQueryable(service: "userService")) {
        self.store = KeychainStore(keychainStoreQueryable: query)
    }
    
    public func insert(_ user: LocalUserItem, completion: @escaping InsertionItemCompletions) {
        let expiredDateInString = TokenHelper.convertStringToDate(dateString: user.expiresIn)
        let localUserDictionary = user.toDictionary()
        do {
            for (k, v) in localUserDictionary {
                try store.setValue(k.rawValue, for: v)
            }
            
            completion(.success(()))
        } catch  let error {
            completion(.failure(error))
        }
    }
    
    public func retrieve() -> LocalUserItem? {
        do {
            guard
                let accessToken = try store.getValue(for: KeychainLocalKeys.accessToken.rawValue),
                let refreshToken = try store.getValue(for: KeychainLocalKeys.refreshToken.rawValue),
                let expiresIn = try store.getValue(for: KeychainLocalKeys.expiresIn.rawValue),
                let role = try store.getValue(for: KeychainLocalKeys.role.rawValue),
                let email = try store.getValue(for: KeychainLocalKeys.email.rawValue),
                let phone = try store.getValue(for: KeychainLocalKeys.phone.rawValue),
                let username = try store.getValue(for: KeychainLocalKeys.username.rawValue),
                let accountId = try store.getValue(for: KeychainLocalKeys.accountId.rawValue) else {
                return nil
            }
            
            return LocalUserItem(accessToken: accessToken, refreshToken: refreshToken, expiresIn: expiresIn, role: role, userName: username, userEmail: email, userMobile: phone, accountId: accountId)
        } catch  {
            return nil
        }
    }
    
    public func remove() {
        do {
            try store.removeAllValues()
        } catch {}
    }
    
}
