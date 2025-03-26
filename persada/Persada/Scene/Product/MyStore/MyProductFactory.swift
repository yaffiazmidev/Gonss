//
//  MyProductFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class MyProductFactory{
    static func createMyProductController(_ isVerified: Bool = false) -> MyProductViewController {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let listLoader = RemoteProductListLoader(url: url, client: client)
        let searchLoader = RemoteProductSearchLoader(url: url, client: client)
        let balanceLoader = RemoteMyStoreBalanceLoader(url: url, client: client)
        let addressLoader = RemoteMyStoreAddressLoader(url: url, client: client)
        
        let controller = MyProductViewController()
        let router = MyProductRouter(controller)
        
        controller.listLoader = listLoader
        controller.searchLoader = searchLoader
        controller.balanceLoader = balanceLoader
        controller.addressLoader = addressLoader
        controller.router = router
        controller.isVerified = isVerified
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
