//
//  Cryptable.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/10/23.
//

import Foundation


/**
 Is a protocol for Crypto. Marks if the class/struct is a cryptographic method.
 */
public protocol Cryptable {
    
    /**
     Encrypts strings with the return data. The return data is string data. You can convert it to a string by making it base64EncodedString()
     
     - parameter string: String.
     - returns: data: Data. Data from an encrypted string
     
     # Example #
     ```
     // Cryptable.encrypt("string to be encrypted")
     ```
     */
    func encrypt(_ string: String) throws -> Data
    
    /**
     Decrypts data from an encrypted string. Returns the original string before it was encrypted. If you only have an encrypted string that has been base64EncodedString(), you can convert that string to data using Data(base64Encoded: base64EncodedString)
     
     - parameter data: Data.
     - returns: string: String.
     
     # Example #
     ```
     // Cryptable.decrypt(Data(base64Encoded: base64EncodedString))
     ```
     */
    func decrypt(_ data: Data) throws -> String
}
