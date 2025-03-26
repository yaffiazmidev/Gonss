//
//  HTTPCLientFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class HTTPClientFactory {
    
    static func makeTimeOutURLSession(interval: TimeInterval) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = interval
        configuration.timeoutIntervalForResource = interval
        return URLSession(configuration: configuration)
    }
    
    static func makeCachedURLSession() -> URLSession {
        let memory = 30 * 1024 * 1024 // 30MB
        let disk = 25 * 1024 * 1024 // 25MB
        let cache = URLCache(memoryCapacity: memory, diskCapacity: disk, directory: nil)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 10.0
        config.urlCache = cache
        
        return URLSession(configuration: config)
    }
    
    static func makeHTTPClient(timeoutInterval: TimeInterval = 10) -> HTTPClient {
        return URLSessionHTTPClient(session: makeTimeOutURLSession(interval: timeoutInterval))
    }
    
    static func makeAuthHTTPClient(timeoutInterval: TimeInterval = 10) -> HTTPClient {
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let httpClient = URLSessionHTTPClient(session: makeTimeOutURLSession(interval: timeoutInterval))

        let keychain = KeychainTokenStore()
        let localTokenLoader = LocalTokenLoader(store: keychain)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        remoteTokenLoader.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        let tokenCache = DiskKeychainTokenCacheDecorator(decoratee: localTokenLoader)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: tokenCache)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: keychain, loader: tokenLoader)
        return authHTTPClient
    }
    
    static func makeCachedAuthHTTPClient() -> HTTPClient {
        let baseURL = URL(string: APIConstants.baseURL)!
        let session = makeCachedURLSession()
        let urlSessionHttpClient = URLSessionHTTPClient(session: session)
        
        let keychain = KeychainTokenStore()
        let localTokenLoader = LocalTokenLoader(store: keychain)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: urlSessionHttpClient)
        remoteTokenLoader.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        let tokenCache = DiskKeychainTokenCacheDecorator(decoratee: localTokenLoader)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: tokenCache)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: urlSessionHttpClient, cache: keychain, loader: tokenLoader)
        let cachedHTTPClient = CachedHTTPClientDecorator(session: session, decoratee: authHTTPClient)

        return cachedHTTPClient
    }
}
