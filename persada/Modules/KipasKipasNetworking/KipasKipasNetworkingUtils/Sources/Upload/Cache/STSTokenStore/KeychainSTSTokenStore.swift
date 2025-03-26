//
//  UserDefaultsSTSTokenStore.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared
import KipasKipasNetworking

class KeychainSTSTokenStore: STSTokenStore {
    
    init(){}
    
    func save(key: String, stsToken: STSTokenItem, completion: @escaping SaveItemCompletion) {
        let itemDictionary = stsToken.toDictionary()
        KKCache.credentials.save(dictionary: itemDictionary, key: KKCache.Key(key))
        completion(.success(()))
    }
    
    
    func load(key: String, completion: @escaping LoadItemCompletion) {
        if let dictionary = KKCache.credentials.readDictionary(key: KKCache.Key(key)) {
            do {
                let item = try STSTokenItem.from(dictionary: dictionary)
                completion(.success(item))
            } catch {
                completion(.failure(KKNetworkError.invalidData))
            }
            return
        }
        
        completion(.failure(KKNetworkError.failedToLoadKeychain(KKNetworkError.keychainNotFound)))
    }
    
    func remove(key: String) {
        KKCache.credentials.remove(key: KKCache.Key(key))
    }
}
