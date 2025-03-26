//
//  ResellerSetProductFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class ResellerSetProductFactory{
    static func createController(_ product: ProductItem) -> ResellerSetProductController {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let setter = RemoteResellerProductSetter(url: url, client: client)
        let updater = RemoteResellerProductUpdater(url: url, client: client)
        let stopper = RemoteResellerProductStopper(url: url, client: client)
        
        let controller = ResellerSetProductController(product)
        controller.setter = setter
        controller.updater = updater
        controller.stopper = stopper
        return controller
    }
    
    static private func makeHTTPClient() -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

        let localTokenLoader = LocalTokenLoader(store: makeKeychainTokenStore())
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: makeKeychainTokenStore(), loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
    
    static private func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
}
