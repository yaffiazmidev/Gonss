//
//  FeedAPIEndpoint.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum CommentAPIEndpoint {
    case comments(postId: String, page: Int)
    case addComment(postId: String, value: String)
    case deleteComment(id: String)
    case likeComment(postId: String, commentId: String, status: String)
    case addSubcomment(postId: String, commentId: String, value: String)
    case deleteSubcomment(id: String)
    case likeSubcomment(postId: String, subcommentId: String, status: String)
    case profile(username: String)
}

extension CommentAPIEndpoint: IEndpoint {
    var path: String {
        switch self {
        case .comments(let postId, _):
            return "comments/feeds/\(postId)"
        case .addComment(let postId, _):
            return "feeds/\(postId)/comment"
        case .addSubcomment(let postId, let commentId, _):
            return "feeds/\(postId)/comment/\(commentId)/comment-sub"
        case .deleteComment(let id):
            return "feeds/comments/\(id)"
        case .deleteSubcomment(let id):
            return "feeds/comment-subs/\(id)"
        case .likeComment(let postId, let commentId, _):
            return "likes/feed/\(postId)/comment/\(commentId)"
        case .likeSubcomment(let postId, let subcommentId, _):
            return "likes/feed/\(postId)/comment-sub/\(subcommentId)"
        case .profile:
           return "/profile/username"
        }
    }
    
    var method: HTTPMethodType {
        switch self {
        case .addComment, .addSubcomment:
            return .put
        case .deleteComment(_), .deleteSubcomment(_):
            return .delete
        case .likeComment(_,_,_), .likeSubcomment(_,_,_):
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
        case .comments(_, let page):
            return ["page" : "\(page)",
                    "size": "10",
                    "sort": "createAt,desc"]
        case .likeComment(_, _, let status), .likeSubcomment(_, _, let status):
            return ["status" : status]
        case .profile(let username):
            return [ "value" : "\(username)"]
        default:
            return [:]
        }
    }
    
    var bodyParamaters: [String : Any] {
        switch self {
        case .addComment(_, let value), .addSubcomment(_, _, let value):
            return ["value": value]
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
