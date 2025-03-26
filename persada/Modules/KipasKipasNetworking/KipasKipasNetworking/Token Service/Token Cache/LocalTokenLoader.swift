//
//  LocalTokenLoader.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public class LocalTokenLoader: TokenLoader {
    
    private let store: TokenStore
    
    public init(store: TokenStore) {
        self.store = store
    }
    
    public func load(request: TokenRequest) async throws -> TokenItem {
        if let token = store.retrieve() {
            let isValid = TokenCachePolicy.validate(expiredDate: token.expiresIn)
            
            if isValid {
                return token.toModel()
            } else {
                throw KKNetworkError.tokenExpired
            }
        } else {
            throw KKNetworkError.tokenNotFound
        }
    }
}

extension LocalTokenLoader: TokenCache {
    
    public func save(_ token: TokenItem, completion: @escaping (TokenCache.Result) -> Void) {
        store.insert(token.toLocal()) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension LocalTokenItem {
    func toModel() -> TokenItem {
        return TokenItem(accessToken: self.accessToken, refreshToken: self.refreshToken, expiresIn: self.expiresIn)
    }
}

private extension TokenItem {
    func toLocal() -> LocalTokenItem {
        return LocalTokenItem(accessToken: self.accessToken, refreshToken: self.refreshToken, expiresIn: self.expiresIn)
    }
}
