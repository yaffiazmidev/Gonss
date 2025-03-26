//
//  NotificationUnreadsService.swift
//  KipasKipas
//
//  Created by DENAZMI on 26/05/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking
import KipasKipasNotification

final class NotificationUnreadsService {
    
    static let shared = NotificationUnreadsService()
    
    lazy var baseURL: URL = {
        return URL(string: APIConstants.baseURL)!
    }()
    
    lazy var tokenStore: TokenStore = {
        return makeKeychainTokenStore()
    }()
    
    lazy var authenticatedHTTPClient: HTTPClient = {
        return makeHTTPClient(baseURL: baseURL).authHTTPClient
    }()
    
    lazy var loader: NotificationUnreadLoader = {
        return RemoteNotificationUnreadLoader(baseURL: baseURL, client: authenticatedHTTPClient)
    }()
    
    var item: NotificationUnreadItem = NotificationUnreadItem()
    
    init() {}
    
    func load(completion: @escaping ((NotificationUnreadItem) -> Void)) {
        loader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                print(error.localizedDescription)
//                completion(self.item)
            case let .success(response):
                self.item = response
                completion(response)
            }
        }
    }
}

extension NotificationUnreadsService {
    func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
    
    func makeKeychainBlockedUserStore() -> BlockedUserStore {
        return KeychainBlockedUserStore()
    }
}

extension NotificationUnreadsService {
    func makeHTTPClient(baseURL: URL) -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        let localTokenLoader = LocalTokenLoader(store: tokenStore)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        remoteTokenLoader.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: tokenStore, loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
}
