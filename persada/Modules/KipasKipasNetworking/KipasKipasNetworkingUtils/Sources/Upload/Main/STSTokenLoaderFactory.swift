//
//  STSTokenLoaderFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class STSTokenLoaderFactory {
    static func create() -> STSTokenLoader {
        let store = KeychainSTSTokenStore()
        let local = LocalSTSTokenLoader(store: store)
        let httpClient = HTTPClientFactory.makeHTTPClient()
        let url = URL(string: UploadConstants.Alibaba.stsEndpoint)!
        let remote = RemoteSTSTokenLoader(url: url, client: httpClient)
        let cacheDecorator = STSTokenLoaderCacheDecorator(decoratee: remote, store: store)
//        let composite = STSTokenLoaderFallbackComposite(primary: local, fallback: cacheDecorator)
        let composite = STSTokenLoaderFallbackComposite(primary: remote, fallback: cacheDecorator)
        
        return composite
    }
}
