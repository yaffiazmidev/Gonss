//
//  TokenLoaderCacheDecorator.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 31/03/22.
//

import Foundation

public class TokenLoaderCacheDecorator: TokenLoader {
    private let decoratee: TokenLoader
    private let cache: TokenCache
    
    public init(decoratee: TokenLoader, cache: TokenCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(request: TokenRequest) async throws -> TokenItem {
        do {
            let token = try await decoratee.load(request: request)
            cache.saveIgnoringResult(token)
            return token
        } catch {
            throw error
        }
    }
}

private extension TokenCache {
    func saveIgnoringResult(_ token: TokenItem) {
        save(token) { _ in }
    }
}
