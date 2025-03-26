//
//  STSTokenCacheDecorator.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class STSTokenLoaderCacheDecorator: STSTokenLoader {
    
    private let decoratee: STSTokenLoader
    private let store: STSTokenStore
    
    init(decoratee: STSTokenLoader, store: STSTokenStore) {
        self.decoratee = decoratee
        self.store = store
    }
    
    func load(request: STSTokenLoaderRequest, completion: @escaping (STSTokenLoader.Result) -> Void) {
        decoratee.load(request: request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(token):
                
                self.store.save(key: request.keystore, stsToken: token) { result in
                    switch result {
                    case .success(_):
                        completion(.success(token))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
        })
        
    }
    
}
