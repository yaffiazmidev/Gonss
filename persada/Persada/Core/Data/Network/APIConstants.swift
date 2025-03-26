//
//  APIConstants.swift
//  Persada
//
//  Created by Muhammad Noor on 06/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

final class APIConstants {
    static private let lock = NSLock()
    static private let currentDomainIndexKey: String = "current_domain_index"
    static private let currentDomainKey: String = "current_domain"
    static private let configureBaseURL: String = Bundle.main.infoDictionary!  ["API_BASE_URL"] as! String
    static private let backupDomainList: [String] = [
        "https://api-main.kipasapi.com/api/v1"
    ]
    
    static func checkDomain(failDomain: String) -> Bool {
        #if Release
        lock.lock()
        defer {
            lock.unlock()
        }
        
        let currentDomain: String? = UserDefaults.standard.value(forKey: currentDomainKey) as? String
        var index = UserDefaults.standard.object(forKey: currentDomainIndexKey) as? Int ?? 0
        if currentDomain != nil && !failDomain.hasPrefix(currentDomain!) {
            return false
        }
        
        print("【Domain】 - APIConstants domain check begin --------")
        var newIndex: Int = 0
        var domain: String = ""
        if index < backupDomainList.count && index >= 0 {
            newIndex = index + 1
            domain = backupDomainList[index]
        } else {
            newIndex = 0
            domain = configureBaseURL
        }
        UserDefaults.standard.setValue(newIndex, forKey: currentDomainIndexKey)
        UserDefaults.standard.setValue(domain, forKey: currentDomainKey)
        UserDefaults.standard.synchronize()
        consoleLog()
        print("【Domain】 - APIConstants domain check over --------")
        return true
        #endif
        
        return false
    }
    
    static func consoleLog() {
        let currentDomain: String = UserDefaults.standard.value(forKey: currentDomainKey) as? String ?? ""
        let index = UserDefaults.standard.object(forKey: currentDomainIndexKey) as? Int ?? 0
        print("【Domain】 - APIConstants domain reset domain \(currentDomain)、index \(index)")
    }
    
    /// Returns `String` representation of server's base URL.
    /**
    - note: Dev environtment is for development purpose, Staging is a mirror environtment from the production for testing purpose.
    */
    static var baseURL: String {
        #if Release
        let domain = UserDefaults.standard.value(forKey: currentDomainKey) as? String ?? configureBaseURL
//        print("【Domain】 - APIConstants baseURL:\(domain)")
        return domain
        #endif
        
        return configureBaseURL
    }
    
    static var uploadURL: String {
        return Bundle.main.infoDictionary!  ["API_UPLOAD_URL"] as! String
    }
    
    static var webURL: String {
        return Bundle.main.infoDictionary! ["API_WEB_URL"] as! String
    }
    
    static var sendbirdAppId: String {
        return Bundle.main.infoDictionary! ["SENDBIRD_APP_ID"] as! String
    }
}

