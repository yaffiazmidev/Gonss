//
//  CallLoginAuthenticatorRequest.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation

public protocol ICallLoginAuthenticatorRequest {
    var userId: String { get }
    var fullName: String { get }
    var pictureUrl: String { get }
}

public struct CallLoginAuthenticatorRequest: ICallLoginAuthenticatorRequest {
    public var fullName: String
    public var pictureUrl: String
    public let userId: String
    
    public init(fullName: String, pictureUrl: String, userId: String) {
        self.fullName = fullName
        self.pictureUrl = pictureUrl
        self.userId = userId
    }
}
