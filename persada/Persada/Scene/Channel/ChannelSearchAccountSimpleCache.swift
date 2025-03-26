//
//  ChannelSearchAccountSimpleCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class ChannelSearchAccountSimpleCache: NSObject {
    
    private static let channelSearchAccountCacheKey = "channelSearchAccountCacheKey"
    
    static let instance = ChannelSearchAccountSimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var getAccounts : [SearchAccount]? {
        if let objects = UserDefaults.standard.value(forKey: ChannelSearchAccountSimpleCache.channelSearchAccountCacheKey) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [SearchAccount] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func saveAccounts(accounts: [SearchAccount]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(accounts){
            UserDefaults.standard.set(encoded, forKey: ChannelSearchAccountSimpleCache.channelSearchAccountCacheKey)
        }
    }
    
}
