//
//  UserDefaultsBlockuserStore.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol UserBlock {
    func save(value: String)
    func getUsersId() -> [String]?
    func delete()
}

class UserDefaultBlockUser: UserBlock {
    private let userDefaults = UserDefaults.standard
    private let userBlock = "usersBlock"
    
    func save(value: String) {
        var items = userDefaults.object(forKey: userBlock) as? [String] ?? []
        items.append(value)
        
        userDefaults.set(items, forKey: userBlock)
    }
    
    func getUsersId() -> [String]? {
        return userDefaults.object(forKey: userBlock) as? [String]
    }
    
    func delete() {
        userDefaults.removeObject(forKey: userBlock)
    }
}

