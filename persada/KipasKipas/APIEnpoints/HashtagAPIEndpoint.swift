//
//  HashtagAPIEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum HashtagAPIEndpoint {
    case getHashtags(value: String, page: Int)
}

extension HashtagAPIEndpoint: IEndpoint {
    var path: String {
        switch self {
        case .getHashtags(_, _):
            return "feeds/search/hashtag"
        }
    }
    
    var method: HTTPMethodType {
        switch self {
        default:
            return .get
        }
    }
    
    var headerParamaters: [String : String] {
        switch self {
        default:
            return [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ]
        }
    }
    
    var queryParameters: [String : Any] {
        switch self {
        case .getHashtags(let hashtag, let page):
            return [
                "value" : hashtag,
                "page" : "\(page)",
                "size" : "10"
            ]
        }
    }
    
    var bodyParamaters: [String : Any] {
        switch self {
        default:
            return [:]
        }
    }
    
    var bodyEncoding: BodyEncoding {
        switch self {
        default:
            return .jsonSerializationData
        }
    }
}
