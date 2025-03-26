//
//  ChannelSearchTopSimpleCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class ChannelSearchTopSimpleCache: NSObject {
    
    private static let channelSearchTopCacheKey = "channelSearchTopCacheKey"
    
    static let instance = ChannelSearchTopSimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var getFeeds: [Feed]? {
        if let objects = UserDefaults.standard.value(forKey: ChannelSearchTopSimpleCache.channelSearchTopCacheKey) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [Feed] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func saveFeeds(feed: [Feed]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(feed){
            UserDefaults.standard.set(encoded, forKey: ChannelSearchTopSimpleCache.channelSearchTopCacheKey)
        }
    }
    
    
    var getAccounts: [SearchAccount]? {
        if let objects = UserDefaults.standard.value(forKey: ChannelSearchTopSimpleCache.channelSearchTopCacheKey) as? Data {
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
    
    func saveAccounts(account: [SearchAccount]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(account){
            UserDefaults.standard.set(encoded, forKey: ChannelSearchTopSimpleCache.channelSearchTopCacheKey)
        }
    }
}
