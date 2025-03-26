//
//  TXIMUser.swift
//  KipasKipasDirectMessage
//
//  Created by MissYasiky on 2024/4/2.
//

import Foundation
import ImSDK_Plus

public class TXIMUser {
    public let userID: String
    public let nickName: String
    public let faceURL: String
    public let isVerified: Bool
    
    public init(userID: String, userName: String, faceURL: String, isVerified: Bool) {
        self.userID = userID
        self.nickName = userName
        self.faceURL = faceURL
        self.isVerified = isVerified
    }
    
    init(user: V2TIMUserFullInfo) {
        self.userID = user.userID
        self.nickName = user.nickName ?? ""
        self.faceURL = user.faceURL ?? ""
        
        var isVerified = false
        if let data = user.customInfo["verified"] {
            if let string = String(data: data, encoding: .utf8) {
                isVerified = (Int(string) ?? (-1)) > 0 ? true : false
            }
        }
        self.isVerified = isVerified
    }
}
