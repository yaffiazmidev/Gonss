//
//  TokenLoaderWithFallbackComposite.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 31/03/22.
//

import Foundation

public class TokenLoaderWithFallbackComposite: TokenLoader {
    private let primary: TokenLoader
    private let fallback: TokenLoader
    
    public init(primary: TokenLoader, fallback: TokenLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(request: TokenRequest) async throws -> TokenItem {
        do {
            let primaryToken = try await primary.load(request: request)
            return primaryToken
        } catch {
            let fallbackToken = try await fallback.load(request: request)
            return fallbackToken
        }
    }
}
