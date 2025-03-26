//
//  FeedSimpleCache.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation


public class FeedSeenCache : NSObject {
    private static let feedCacheKey = "feedSeenCacheKey"
    
    public static let instance = FeedSeenCache()
    private let userDefaults: UserDefaults
    private let suiteName = "FeedCache"
    
    override init() {
        userDefaults = UserDefaults(suiteName: suiteName)!
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func getSeenFeeds(forKey identifier: String) -> [FeedId] {
        if let objects = userDefaults.value(forKey: FeedSeenCache.feedCacheKey + "\(identifier)") as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [FeedId] {
                //print("****debugDup getSeenFeeds \(identifier) count:", objectsDecoded.count)
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }

    public func removeAllSeenFeed() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }

    func saveSeenFeed(feedId: FeedId, forKey identifier: String) {
        let encoder = JSONEncoder()
        //let savedFeeds = getSeenFeeds(forKey: FeedSeenCache.feedCacheKey + "\(identifier)")
        var savedFeeds = getSeenFeeds(forKey: identifier)
        
        if savedFeeds.contains(where: { $0.id == feedId.id }) {
            // feed.id already in cache, do nothing..
            if let index = savedFeeds.firstIndex(where: { $0.id == feedId.id }){
                savedFeeds[index] = feedId
                if let encoded = try? encoder.encode(savedFeeds){
                    userDefaults.set(encoded, forKey: FeedSeenCache.feedCacheKey + "\(identifier)")
                }
            }
        } else {
            if let encoded = try? encoder.encode([feedId] + savedFeeds){
                userDefaults.set(encoded, forKey: FeedSeenCache.feedCacheKey + "\(identifier)")
            }
        }        
    }
    
}


