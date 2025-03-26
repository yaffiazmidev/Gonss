//
//  FeedAPIEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum FeedAPIEndpoint {
    case getChannelContentsBy(id: String, page: Int)
}

extension FeedAPIEndpoint: IEndpoint {
    var path: String {
        switch self {
        case .getChannelContentsBy(let channelId, _):
            return "feeds/channel/\(channelId)"
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
        case .getChannelContentsBy(_, let page):
            return [
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
