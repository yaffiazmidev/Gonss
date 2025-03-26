//
//  ChannelAPIEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ChannelAPIEndpoint {
    case all(page: Int)
    case following(page: Int)
    case generalPost(page: Int)
    case channel(id: String)
    case followChannel(id: String)
    case unfollowChannel(id: String)
    
    //MARK: Public
    case publicAll(page: Int)
    case publicGeneralPost(page: Int)
}

extension ChannelAPIEndpoint: IEndpoint {
    var path: String {
        switch self {
        case .all:
            return "channels"
        case .following:
            return "channels/me/follow"
        case .generalPost:
            return "channels/general/posts"
        case .channel(let id):
            return "channels/\(id)"
        case .followChannel(let id):
            return "channels/\(id)/follow"
        case .unfollowChannel(let id):
            return "channels/\(id)/unfollow"
        
        //MARK: Public
        case .publicAll:
            return "public/channels"
        case .publicGeneralPost:
            return "public/channels/general/posts"
        }
    }
    
    var method: HTTPMethodType {
        switch self {
        case .followChannel, .unfollowChannel:
            return .patch
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
        case .all(let page), .publicAll(let page), .publicGeneralPost(page: let page):
            return ["page": page]
        case .generalPost(let page), .following(let page):
            return [
                "page" : page,
                "size": "10",
                "sort" : "createAt,desc"
            ]
        default:
            return [:]
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
