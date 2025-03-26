//
//  LoginPreference.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class LoginPreference : NSObject {
    private static let loginEmailKey = "loginEmailKey"
    
    static let instance = LoginPreference()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var email: String? {
                 get {
                         return userDefaults.string(forKey: LoginPreference.loginEmailKey)
                 }
                 set(newValue) {
                         if let value = newValue {
                                 userDefaults.set(value, forKey: LoginPreference.loginEmailKey)
                         }else {
                                 userDefaults.removeObject(forKey: LoginPreference.loginEmailKey)
                         }
                 }
         }
}
