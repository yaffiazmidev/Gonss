//
//  AuthenticatedMediaUploaderRequest.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/11/23.
//

import Foundation

public struct AuthenticatedMediaUploaderRequest: MediaUploaderRequestable {
    public let media: Data
    public let ext: String
    public var username: String?
    public var password: String?
    public var token: STSTokenItem?
    
    public init(media: Data, ext: String, username: String? = nil, password: String? = nil, token: STSTokenItem? = nil) {
        self.media = media
        self.ext = ext
        self.username = username
        self.password = password
        self.token = token
    }
}

public extension AuthenticatedMediaUploaderRequest {
    static func from(request: MediaUploaderRequestable) -> AuthenticatedMediaUploaderRequest {
        return AuthenticatedMediaUploaderRequest(media: request.media, ext: request.ext)
    }
    
    static func from(request: MediaUploaderRequestable, username: String, password: String) -> AuthenticatedMediaUploaderRequest {
        return AuthenticatedMediaUploaderRequest(
            media: request.media,
            ext: request.ext,
            username: username,
            password: password
        )
    }
}
