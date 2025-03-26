//
//  VerifyIdentityStoredKeychainStore.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 06/06/24.
//

import Foundation
import KipasKipasShared

public struct VerifyIdentityStored: Codable {
    public var userEmail, userMobile: String
    public var isEmailUpdated: Bool
    public var isPhoneNumberUpdated: Bool
    
    public init(
        userEmail: String = "",
        userMobile: String = "",
        isEmailUpdated: Bool = false,
        isPhoneNumberUpdated: Bool = false
    ) {
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.isEmailUpdated = isEmailUpdated
        self.isPhoneNumberUpdated = isPhoneNumberUpdated
    }
}

public final class VerifyIdentityStoredKeychainStore {
    
    private var keychain: KKCaching {
        return KKCache.credentials
    }
    
    private let key: KKCache.Key = .verifyIdentity
    
    public typealias InsertionResult = Swift.Result<Void, Error>
    
    public init() {}
   
    public func insert(_ data: VerifyIdentityStored, completion: @escaping (InsertionResult) -> Void) {
        do {
            try keychain.save(value: data, key: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func retrieve() -> VerifyIdentityStored? {
        return try? keychain.read(type: VerifyIdentityStored.self, key: key)
    }
    
    public func remove() {
        return keychain.remove(key: key)
    }
}
