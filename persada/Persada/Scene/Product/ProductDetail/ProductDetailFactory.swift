//
//  ProductDetailComposer.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class ProductDetailFactory{
    static func createProductDetailController(dataSource: Product?, account: Profile? = nil, isPreview: Bool = false) -> ProductDetailController{
        let reviewLoader = RemoteReviewLoader(url: URL(string: APIConstants.baseURL)!, client: AUTH.isLogin() ? makeHTTPClient().authHTTPClient : makeHTTPClient().httpClient)
        let reviewMediaLoader = RemoteReviewMediaLoader(url: URL(string: APIConstants.baseURL)!, client: AUTH.isLogin() ? makeHTTPClient().authHTTPClient : makeHTTPClient().httpClient)
        
        let vc = ProductDetailController(mainView: ProductDetailView(), dataSource: dataSource, isPreview: isPreview, reviewLoader: reviewLoader, reviewMediaLoader: reviewMediaLoader)
        return vc
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
