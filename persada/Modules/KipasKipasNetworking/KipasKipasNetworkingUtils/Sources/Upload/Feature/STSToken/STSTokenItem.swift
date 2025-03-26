//
//  STSTokenLoaderItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

public struct STSTokenItem {
    public let securityToken: String
    public let accessKeyID: String
    public let accessKeySecret: String
    public let expiration: Date
    
    public enum Key: String {
        case securityToken = "security_token"
        case accessKeyID = "access_key_id"
        case accessKeySecret = "access_key_secret"
        case expiration = "expiration"
    }
    
    public init(securityToken: String, accessKeyID: String, accessKeySecret: String, expiration: Date){
        self.securityToken = securityToken
        self.accessKeyID = accessKeyID
        self.accessKeySecret = accessKeySecret
        self.expiration = expiration
    }
}


public extension STSTokenItem {
    func toDictionary() -> [String: String] {
        return [
            Key.securityToken.rawValue: securityToken,
            Key.accessKeyID.rawValue: accessKeyID,
            Key.accessKeySecret.rawValue: accessKeySecret,
            Key.expiration.rawValue: STSTokenHelper.convertDateToString(date: expiration)
        ]
    }
    
    static func from(dictionary data: [String: Any]) throws -> STSTokenItem {
        guard let securityToken = data[Key.securityToken.rawValue] as? String,
              let accessKeyID = data[Key.accessKeyID.rawValue] as? String,
              let accessKeySecret = data[Key.accessKeySecret.rawValue] as? String,
              let expirationString = data[Key.expiration.rawValue] as? String,
              let expirationDate = STSTokenHelper.convertStringToDate(dateString: expirationString) else {
            throw KKNetworkError.invalidData
        }
        
        return STSTokenItem(securityToken: securityToken, accessKeyID: accessKeyID, accessKeySecret: accessKeySecret, expiration: expirationDate)
    }
}
