//
//  ProductSheetFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking
import UIKit

class ProductSheetFactory{
    static func show(from parent: UIViewController, feed: Feed, products p: [ProductItem]?, delegate: ProductSheetDelegate) {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let listLoader = RemoteProductListLoader(url: url, client: client)
        
        ProductSheetView.openSheet(
            from: parent,
            loader: listLoader,
            feed: feed,
            products: p,
            delegate: delegate
        )
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
