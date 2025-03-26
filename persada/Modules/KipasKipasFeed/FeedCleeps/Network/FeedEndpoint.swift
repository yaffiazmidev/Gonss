//
//  FeedEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum FeedEndpoint {
    case staticStory(page: Int)
    case story(page: Int)
    case publicStory(page: Int)
    case staticHome(page: Int)
    case home(page: Int)
    case homeAsGuest(page: Int)
    case byChannelId(id: String, page: Int)
    case tiktok(code: String, page: Int, size: Int)
    case feedTikTok(code: String, page: Int, size: Int)
    case deletePost(id: String)
    case postDetail(id: String)
    case newsDetail(id: String)
    case newsDetailPublic(id: String)
    case newsDetailUnivLink(id: String)
    case newsDetailPublicUnivLink(id: String)
    case following(page: Int)
    case shop(page: Int)
    case donation(page: Int)
    case donationDetail(id: String)
    case likeFeed(id: String, status: String)
    case rxlikeFeed(id: String, status: String)
    case comments(id: String, page: Int)
    case deleteComment(id: String)
    case subcomment(id: String, page: Int)
    case commentLike(id: String, commentId: String, status: String)
    case subcommentLike(id: String, subcommentId: String, status: String)
    case addComment(id: String, value: String)
    case addSubcomment(id: String, commentId: String, value: String)
    case address
    case byProfileId(id: String, page: Int)
    case byProfileIdWithSize(id: String, page: Int, size: Int)
    case latest(id: String)
    case deleteSubComment(id: String)
    case deleteStory(idStories: String, idFeeds: String)
    case updateFeedAlreadySeen(feedId: String)
}

extension FeedEndpoint: EndpointType {
    
    var method: HTTPMethod {
        switch self {
            case .deletePost(_), .deleteComment(_), .deleteSubComment(_):
            return .delete
        case .likeFeed(_,_), .commentLike(_,_,_), .subcommentLike(_,_,_):
            return .patch
        case .addComment(_,_), .addSubcomment(_,_,_):
            return .put
        default:
            return .get
        }
    }
    
    var body: [String : Any] {
        switch self {
        case .addComment(_, let value), .addSubcomment(_,_, let value):
            return [ "value" : value ]
        default:
            return [:]
        }
    }
    
    var baseUrl: URL {
        return URL(string: HelperSingleton.shared.baseURL)!
    }
    
    var path: String {
        switch self {
        case .staticHome:
            return "/statics/feeds/post/home"
        case .home:
            return "/feeds/post/home"
        case .homeAsGuest:
            return "/public/feeds/post/home"
        case .newsDetail(let value), .postDetail(let value):
            return "/feeds/\(value)"
        case .newsDetailPublic(let value):
            return "/public/feeds/\(value)"
        case .following:
            return "/feeds/post/following"
        case .staticStory:
            return "/statics/stories"
        case .story:
            return "/stories"
        case .publicStory:
            return "/public/feeds/post/story"
        case .deleteStory(let idStories, let idFeeds):
            return "/stories/\(idStories)/feeds/\(idFeeds)"
        case .shop:
            return "/feeds/post/product"
        case .donation:
            return "/feeds/post/donation"
        case .donationDetail(let id):
            return "/feeds/\(id)"
        case .likeFeed(let id, _):
            return "/likes/feed/\(id)"
        case .comments(let id,_):
            return "/comments/feeds/\(id)"
        case .subcomment(let id, _):
            return "/comments/\(id)/comment-subs"
        case .commentLike(let id, let commentId, _):
            return "/likes/feed/\(id)/comment/\(commentId)"
        case .subcommentLike(let id, let subcommentId, _):
            return "/likes/feed/\(id)/comment-sub/\(subcommentId)"
        case .addComment(let id,_):
            return "/feeds/\(id)/comment"
        case .addSubcomment(let id, let commentId, _):
            return "/feeds/\(id)/comment/\(commentId)/comment-sub"
        case .address:
            return "/addresses/account"
        case .deletePost(let id):
            return "/feeds/\(id)"
        case .rxlikeFeed(id: let id, _):
            return "/likes/feed/\(id)"
        case .byChannelId(let id, _):
                return "/feeds/channel/\(id)"
        case .tiktok:
            if(DebugMode().isModule(moduleName: "test")){
                return "/feeds/channels/test/"
            }
            return "/feeds/channels/"
        case .feedTikTok:
            if(DebugMode().isModule(moduleName: "test")){
                return "/feeds/post/home/test/"
            }
            return "/feeds/post/home/"
        case .byProfileId(let id, _), .latest(let id), .byProfileIdWithSize( let id, _,_):
                return "/profile/post/\(id)"
            case .deleteComment(let id):
                return "/feeds/comments/\(id)"
            case .deleteSubComment(let id):
            return "/feeds/comment-subs/\(id)"
        case .updateFeedAlreadySeen(let id):
            return "/feeds/\(id)/seen"
        case .newsDetailUnivLink(let id):
            return "/feeds/id-news/\(id)"
        case .newsDetailPublicUnivLink(let id):
            return "/public/feeds/id-news/\(id)"
        }
    }

    var header: [String : String]  {
            return [
                "Authorization" : "Bearer \(HelperSingleton.shared.token)",
                "Content-Type":"application/json",
            ]
        
    }
    
    var parameter: [String : Any] {
        switch self {
        case .home(let page), .following(let page), .donation(let page), .shop(let page):
            return [
                "page" : "\(page)",
                "direction": "DESC",
                "sort": "id"
            ]
        case .homeAsGuest(page: let page):
            return [
                "size": "10",
                "page": "\(page)",
                "sort": "createAt,desc"
            ]
        case .subcomment(_, let page), .comments(_, let page):
            return [
                "page" : "\(page)",
                "sort": "createAt,desc"
            ]
        case .story(let page), .publicStory(let page), .staticStory(let page):
            return ["page": "\(page)"]
        case .likeFeed(_,let status), .commentLike(_, _, let status),
             .subcommentLike(_, _, let status), .rxlikeFeed(_,let status):
            return [
                "status" : status
            ]
            case .byChannelId(id: _, let page), .byProfileId(_, let page):
                return [
                    "page": "\(page)"
                ]
        case .latest(id: _):
            return [
                "size": "1",
                "page": "0"
            ]
        case let .byProfileIdWithSize(_, page, size):
            return [
                "page": "\(page)",
                "size": size
            ]
        case let .tiktok(code, page, size), let .feedTikTok(code, page, size):
            return [
                "code": "\(code)",
                "page": "\(page)",
                "size": size
            ]
        default:
            return [:]
        }
    }
}
