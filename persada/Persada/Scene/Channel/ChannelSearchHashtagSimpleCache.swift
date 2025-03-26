//
//  ChannelSearchHashtagSimpleCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class ChannelSearchHashtagSimpleCache: NSObject {
    
    private static let channelSearchHashtagCacheKey = "channelSearchHashtagCacheKey"
    
    static let instance = ChannelSearchHashtagSimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var getHashtags: [Hashtag]? {
        if let objects = UserDefaults.standard.value(forKey: ChannelSearchHashtagSimpleCache.channelSearchHashtagCacheKey) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [Hashtag] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    func saveHastags(hashtag: [Hashtag]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(hashtag){
            UserDefaults.standard.set(encoded, forKey: ChannelSearchHashtagSimpleCache.channelSearchHashtagCacheKey)
        }
    }
    
}
