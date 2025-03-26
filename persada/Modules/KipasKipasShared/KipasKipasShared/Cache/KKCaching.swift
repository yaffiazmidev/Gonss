//
//  KKCaching.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/10/23.
//

import Foundation


/**
 Is a protocol for Cache in KipasKipas.
 */
public protocol KKCaching {
    
    
    /**
     Gets an instance of KKCaching
     - returns: KKCaching
     # Example #
     ```
     // KKCaching.instance
     ```
     */
    static var instance: KKCaching { get }
    
    /**
     Method for storing Data with a defined key.
     
     - parameter data: Data.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(data: Data(), key: KKCache.Key("data"))
     ```
     */
    func save(data: Data, key: KKCache.Key)
    
    /**
     Method for storing Data with a defined key.
     
     - parameter data: T.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(value: Codable, key: {key})
     ```
     */
    func save<T: Codable>(value: T, key: KKCache.Key) throws
    
    /**
     Method for storing String with a defined key.
     
     - parameter data: String.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(string: "data string", key: KKCache.Key("string"))
     ```
     */
    func save(string: String, key: KKCache.Key)
    
    /**
     Method for storing Boolean with a defined key.
     
     - parameter bool: Bool.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(bool: true, key: KKCache.Key("bool"))
     ```
     */
    func save(bool: Bool, key: KKCache.Key)
    
    /**
     Method for storing Integer with a defined key.
     
     - parameter integer: Int.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(integer: 101, key: KKCache.Key("integer"))
     ```
     */
    func save(integer: Int, key: KKCache.Key)
    
    /**
     Method for storing Array with a defined key.
     
     - parameter array: [Any].
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(array: [101, "string", true], key: KKCache.Key("array"))
     ```
     */
    func save(array: [Any], key: KKCache.Key)
    
    /**
     Method for storing Dictionary<String, Any> with a defined key.
     
     - parameter dictionary: [String: Any].
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(dictionary: ["bool": true, "integer": 101], key: KKCache.Key("dictionary"))
     ```
     */
    func save(dictionary: [String: Any], key: KKCache.Key)
    
    /**
     Method for storing Double with a defined key.
     
     - parameter double: Double.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(double: 2.0, key: KKCache.Key("double"))
     ```
     */
    func save(double: Double, key: KKCache.Key)
    
    /**
     Method for storing Float with a defined key.
     
     - parameter float: Float.
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.save(float: 3.01, key: KKCache.Key("float"))
     ```
     */
    func save(float: Float, key: KKCache.Key)
    
    /**
     Method for getting Data with a defined key
     - parameter key: KKCache.Key.
     - returns: T?
     
     # Example #
     ```
     // KKCaching.instance.readData(type: Codable.self, key: KKCache.Key("data"))
     ```
     */
    func read<T: Codable>(type: T.Type, key: KKCache.Key) throws -> T?
    
    /**
     Method for getting Data with a defined key
     - parameter key: KKCache.Key.
     - returns: Data?
     
     # Example #
     ```
     // KKCaching.instance.readData(key: KKCache.Key("data"))
     ```
     */
    func readData(key: KKCache.Key) -> Data?
    
    /**
     Method for getting String with a defined key
     - parameter key: KKCache.Key.
     - returns: String?
     
     # Example #
     ```
     // KKCaching.instance.readString(key: KKCache.Key("string"))
     ```
     */
    func readString(key: KKCache.Key) -> String?
    
    /**
     Method for getting Bool with a defined key
     - parameter key: KKCache.Key.
     - returns: Bool?
     
     # Example #
     ```
     // KKCaching.instance.readBool(key: KKCache.Key("bool"))
     ```
     */
    func readBool(key: KKCache.Key) -> Bool?
    
    /**
     Method for getting Integer with a defined key
     - parameter key: KKCache.Key.
     - returns: Int?
     
     # Example #
     ```
     // KKCaching.instance.readInteger(key: KKCache.Key("integer"))
     ```
     */
    func readInteger(key: KKCache.Key) -> Int?
    
    /**
     Method for getting Array with a defined key
     - parameter key: KKCache.Key.
     - returns: [Any]?
     
     # Example #
     ```
     // KKCaching.instance.readArray(key: KKCache.Key("array"))
     ```
     */
    func readArray(key: KKCache.Key) -> [Any]?
    
    /**
     Method for getting Dictionary<String: Any> with a defined key
     - parameter key: KKCache.Key.
     - returns: [String: Any]?
     
     # Example #
     ```
     // KKCaching.instance.readDictionary(key: KKCache.Key("dictionary"))
     ```
     */
    func readDictionary(key: KKCache.Key) -> [String: Any]?
    
    /**
     Method for getting Double with a defined key
     - parameter key: KKCache.Key.
     - returns: Double?
     
     # Example #
     ```
     // KKCaching.instance.readDouble(key: KKCache.Key("double"))
     ```
     */
    func readDouble(key: KKCache.Key) -> Double?
    
    /**
     Method for getting Float with a defined key
     - parameter key: KKCache.Key.
     - returns: Float?
     
     # Example #
     ```
     // KKCaching.instance.readFloat(key: KKCache.Key("float"))
     ```
     */
    func readFloat(key: KKCache.Key) -> Float?
    
    
    /**
     Method for deleting data stored with a defined key
     - parameter key: KKCache.Key.
     
     # Example #
     ```
     // KKCaching.instance.remove(key: KKCache.Key("dictionary"))
     ```
     */
    func remove(key: KKCache.Key)
    
    /**
     Method for deleting all data stored via KKCaching with a defined key
     
     # Example #
     ```
     // KKCaching.instance.clear()
     ```
     */
    func clear()
}
