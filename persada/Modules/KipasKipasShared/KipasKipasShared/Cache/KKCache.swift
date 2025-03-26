//
//  KKCache.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/10/23.
//

import Foundation


/**
 This is a class for managing cache on KipasKipas
 */
public class KKCache {
    
    private init(){}
    
    
    /**
     Get a KKCaching instance with common level. Used to store Cache for regular data.
     - returns: KKCaching
     
     # Notes: #
     1. This instance is an instance of UserDefaultsKKCache.
     
     # Example #
     ```
     // KKCache.common
     ```
     */
    public class var common: KKCaching {
        get {
            return UserDefaultsKKCache.instance
        }
    }
    
    /**
     Get a KKCaching instance with credentials level. Used to store Cache for credentials data.
     - returns: KKCaching
     
     # Notes: #
     1. This instance is an instance of KeychainKKCache.
     
     # Example #
     ```
     // KKCache.credentials
     ```
     */
    public class var credentials: KKCaching {
        get {
            return KeychainKKCache.instance
        }
    }
    
    /**
     Method to delete all data for common and credential levels stored via KKCache/KKCaching.
     # Example #
     ```
     // KKCache.clear()
     ```
     */
    public class func clear() {
        common.clear()
        credentials.clear()
    }
}

// MARK: - Key
public extension KKCache {
    class Key {
        public var rawValue: String
        
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
