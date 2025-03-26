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
    
    private static var client: HTTPClient?
    
    static func makeTimeOutURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0

        return URLSession(configuration: configuration)
    }
    
    static func makeHTTPClient() -> HTTPClient {
        return URLSessionHTTPClient(session: makeTimeOutURLSession())
    }
    
//    static func makeAuthHTTPClient() -> HTTPClient {
//        
//        if let client = client {
//            return client
//        }
//        
//        let baseURL = URL(string: APIConstants.baseURL)!
//        
//        let httpClient = URLSessionHTTPClient(session: makeTimeOutURLSession())
//
//        let keychain = KeychainTokenStore()
//        let localTokenLoader = LocalTokenLoader(store: keychain)
//        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient, minusSecond: TokenExpiredHelper.getMinusSecond())
//        let tokenCache = DiskKeychainTokenCacheDecorator(decoratee: localTokenLoader)
//        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: tokenCache)
//        let tokenLoader = TokenLoaderWithFallbackComposite(primary: localTokenLoader, fallback: fallbackTokenLoader)
//        
//        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: keychain, loader: tokenLoader)
//        client = authHTTPClient
//        return authHTTPClient
//    }
    
}
