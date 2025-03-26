//
//  BaseFeedPreference.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class BaseFeedPreference : NSObject {
    private static let isScrolledKey = "isScrolledKey"
    private static let isDetailKey = "isScrollDetailKey"
    private static let lastIndexKey = "lastIndexKey"
    
    static let instance = BaseFeedPreference()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    private init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var isScroll : Bool {
                get {
                    return userDefaults.bool(forKey: BaseFeedPreference.isScrolledKey)
                }
                set (newValue) {
                        userDefaults.set(newValue, forKey: BaseFeedPreference.isScrolledKey)
                }
        }
    
    var isDetail : Bool {
                get {
                        return userDefaults.bool(forKey: BaseFeedPreference.isDetailKey)
                }
                set (newValue) {
                        userDefaults.set(newValue, forKey: BaseFeedPreference.isDetailKey)
                }
        }
    
    var lastIndex : Int {
        get {
                return userDefaults.integer(forKey: BaseFeedPreference.lastIndexKey)
        }
        set (newValue) {
                userDefaults.set(newValue, forKey: BaseFeedPreference.lastIndexKey)
        }
    }
    
    func saveIndex(key: String, value: Int){
        userDefaults.set(value, forKey: key)
    }
    
    func getIndex(key: String) ->  Int? {
        return userDefaults.integer(forKey: key)
    }
}
