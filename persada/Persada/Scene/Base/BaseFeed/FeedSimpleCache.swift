//
//  FeedSimpleCache.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation


class FeedSimpleCache : NSObject {
    private static let feedCacheKey = "feedCacheKey"
    
    static let instance = FeedSimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func saveValue(key: String, value: Bool){
       userDefaults.set(value, forKey: key)
    }
    
    func getValue(key: String) -> Bool? {
        return userDefaults.bool(forKey: key)
    }
    
    var getFeeds : [Feed]? {
        print("FROM CACHE FEEDS 1 \(self)")
        if let objects = UserDefaults.standard.value(forKey: FeedSimpleCache.feedCacheKey) as? Data {
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
    
    func saveFeeds(feeds: [Feed]) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(feeds){
             UserDefaults.standard.set(encoded, forKey: FeedSimpleCache.feedCacheKey)
          }
     }
}


