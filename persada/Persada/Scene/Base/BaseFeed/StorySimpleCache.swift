//
//  StorySimpleCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class StorySimpleCache: NSObject {
    
    private static let storyCacheKey = "storyCacheKey"
    
    static let instance = StorySimpleCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var getStories : [StoriesItem]? {
        if let objects = UserDefaults.standard.value(forKey: StorySimpleCache.storyCacheKey) as? Data {
             let decoder = JSONDecoder()
             if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [StoriesItem] {
                return objectsDecoded
             } else {
                return []
             }
          } else {
             return []
          }
       }
    
    func saveStories(stories: [StoriesItem]) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(stories){
             UserDefaults.standard.set(encoded, forKey: StorySimpleCache.storyCacheKey)
          }
     }
    
}
