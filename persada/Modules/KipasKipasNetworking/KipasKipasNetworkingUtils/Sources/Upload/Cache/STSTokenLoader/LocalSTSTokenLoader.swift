//
//  LocalSTSTokenLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class LocalSTSTokenLoader: STSTokenLoader {
    private let store: STSTokenStore
    
    init(store: STSTokenStore){
        self.store = store
    }
    
    func load(request: STSTokenLoaderRequest, completion: @escaping (STSTokenLoader.Result) -> Void) {
        store.load(key: request.keystore) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                //let isValid = STSTokenCachePolicy.validate(expiredDate: item.expiration)
                let isValid = false // PE-14268
                if isValid {
                    completion(.success(item))
                    return
                }
                
                self.store.remove(key: request.keystore)
                completion(.failure(KKNetworkError.tokenExpired))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
