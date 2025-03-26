//
//  DetailTransactionDonationFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class DetailTransactionDonationFactory{
    static func createSuccessController(_ orderId: String) -> DetailTransactionDonationSuccessController {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let loader  = RemoteDetailTransactionOrderLoader(url: url, client: client)
        
        let controller = DetailTransactionDonationSuccessController(orderId)
        controller.loader = loader
        return controller
    }
    
    static func createWaitingController(_ orderId: String) -> DetailTransactionDonationWaitingController {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let loader  = RemoteDetailTransactionOrderLoader(url: url, client: client)
        
        let controller = DetailTransactionDonationWaitingController(orderId)
        controller.loader = loader
        return controller
    }
    
    static func createExpiredController(_ orderId: String) -> DetailTransactionDonationExpiredController {
        let url = URL(string: APIConstants.baseURL)!
        let client = makeHTTPClient().authHTTPClient
        let loader  = RemoteDetailTransactionOrderLoader(url: url, client: client)
        
        let controller = DetailTransactionDonationExpiredController(orderId)
        controller.loader = loader
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
