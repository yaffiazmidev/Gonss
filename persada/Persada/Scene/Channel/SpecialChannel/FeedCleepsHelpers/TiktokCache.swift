//
//  KipasCache.swift
//  KipasKipas
//
//  Created by PT.Koanba on 17/11/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class TiktokCache : NSObject {
    
    static let instance = TiktokCache()
    private let userDefaults: UserDefaults
    private static let isDarkKey = "isDarkKey"

    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func saveValue(key: String, value: String){
       userDefaults.set(value, forKey: key)
    }
    
    func getValue(key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func removeObject(key: String){
        return userDefaults.removeObject(forKey: key)
    }
    
    var isDark: Bool {
                get {
                        return userDefaults.bool(forKey: TiktokCache.isDarkKey)
                }
                set (newValue) {
                        userDefaults.set(newValue, forKey: TiktokCache.isDarkKey)
                }
        }
    
    func getFeeds(with key: TikTokCountry) -> ([Feed]?) {
        if let objects = UserDefaults.standard.value(forKey: "cleepsKeyForCountry\(key.rawValue)") as? Data {
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
    
    func saveFeeds(feeds: [Feed], for key: TikTokCountry) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(feeds){
              UserDefaults.standard.set(encoded, forKey: "cleepsKeyForCountry\(key.rawValue)")
          }
     }
}
