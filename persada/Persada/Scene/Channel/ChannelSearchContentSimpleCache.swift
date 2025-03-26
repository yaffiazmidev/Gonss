//
//  ChannelSearchContentSimpleCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class ChannelSearchContentSimpleCache: NSObject {
    
    private static let channelSearchContentCacheKey = "channelSearchContentCacheKey"
    
    static let instance = ChannelSearchContentSimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var getChannels: [ChannelData]? {
        if let objects = UserDefaults.standard.value(forKey: ChannelSearchContentSimpleCache.channelSearchContentCacheKey) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [ChannelData] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func saveChannels(accounts: [ChannelData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(accounts){
            UserDefaults.standard.set(encoded, forKey: ChannelSearchContentSimpleCache.channelSearchContentCacheKey)
        }
    }
    
}
