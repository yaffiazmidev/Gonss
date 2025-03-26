//
//  TUICallLoginAuthenticatorRequest.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation

public struct TUICallLoginAuthenticatorRequest: ICallLoginAuthenticatorRequest {
    public var fullName: String
    public var pictureUrl: String
    public var userId: String
    
    public let sdkAppId: UInt32
    public let userSig: String
    
    public init(fullName: String, pictureUrl: String, userId: String, sdkAppId: UInt32, userSig: String) {
        self.fullName = fullName
        self.pictureUrl = pictureUrl
        self.userId = userId
        self.sdkAppId = sdkAppId
        self.userSig = userSig
    }
}
