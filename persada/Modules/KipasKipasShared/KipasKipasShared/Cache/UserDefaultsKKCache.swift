//
//  UserDefaultsKKCache.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/10/23.
//

import Foundation

public class UserDefaultsKKCache: KKCaching {
    
    private static var _instance: KKCaching?
    private static let lock = NSLock()
    
    private var defaults: UserDefaults = UserDefaults.standard
    private var identifier: String = "UserDefaultsKKCache"
    
    private init(){}
    
    public static var instance: KKCaching {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = UserDefaultsKKCache()
            }
        }
        return _instance!
    }
    
    public func save(data: Data, key: KKCache.Key) {
        defaults.set(data, forKey: generate(key))
    }
    
    public func save(string: String, key: KKCache.Key) {
        defaults.set(string, forKey: generate(key))
    }
    
    public func save(bool: Bool, key: KKCache.Key) {
        defaults.set(bool, forKey: generate(key))
    }
    
    public func save(integer: Int, key: KKCache.Key) {
        defaults.set(integer, forKey: generate(key))
    }
    
    public func save(array: [Any], key: KKCache.Key) {
        defaults.set(array, forKey: generate(key))
    }
    
    public func save(dictionary: [String : Any], key: KKCache.Key) {
        defaults.set(dictionary, forKey: generate(key))
    }
    
    public func save(double: Double, key: KKCache.Key) {
        defaults.set(double, forKey: generate(key))
    }
    
    public func save(float: Float, key: KKCache.Key) {
        defaults.set(float, forKey: generate(key))
    }
    
    public func readData(key: KKCache.Key) -> Data? {
        return defaults.data(forKey: generate(key))
    }
    
    public func readString(key: KKCache.Key) -> String? {
        return defaults.string(forKey: generate(key))
    }
    
    public func save<T: Codable>(value: T, key: KKCache.Key) throws {
        return defaults.set(value, forKey: generate(key))
    }
    
    public func read<T:Codable>(type: T.Type, key: KKCache.Key) throws -> T? {
        return defaults.value(forKey: generate(key)) as? T
    }
    
    public func readBool(key: KKCache.Key) -> Bool? {
        return defaults.bool(forKey: generate(key))
    }
    
    public func readInteger(key: KKCache.Key) -> Int? {
        return defaults.integer(forKey: generate(key))
    }
    
    public func readArray(key: KKCache.Key) -> [Any]? {
        return defaults.array(forKey: generate(key))
    }
    
    public func readDictionary(key: KKCache.Key) -> [String : Any]? {
        return defaults.dictionary(forKey: generate(key))
    }
    
    public func readDouble(key: KKCache.Key) -> Double? {
        return defaults.double(forKey: generate(key))
    }
    
    public func readFloat(key: KKCache.Key) -> Float? {
        return defaults.float(forKey: generate(key))
    }
    
    public func remove(key: KKCache.Key) {
        defaults.removeObject(forKey: generate(key))
    }
    
    public func clear() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if key.contains(identifier) {
                defaults.removeObject(forKey: key)
            }
        }
    }
}

private extension UserDefaultsKKCache {
    private func generate(_ key: KKCache.Key) -> String {
        return "\(identifier)-\(key.rawValue)"
    }
}
