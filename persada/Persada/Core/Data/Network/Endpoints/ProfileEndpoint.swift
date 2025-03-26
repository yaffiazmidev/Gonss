//
//  ProfileEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 04/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ProfileEndpoint {
	case unfollowAccount(id: String)
	case followAccount(id: String)
	case profile(id: String)
	case profileUsername(text: String)
	case postAccount(id: String, type: String, page: Int)
	case searchFollowers(id: String, name: String, page: Int)
	case searchFollowing(id: String, name: String, page: Int)
	case followers(id: String)
	case totalPost(id: String)
	case listFollowers(id:String, page: Int)
	case followings(id: String)
	case listFollowings(id:String, page: Int)
	case followChannel(id: String)
	case unfollowChannel(id: String)
    case updateAccount(id: String, bio: String?, name: String?, photo: String?, birthDate: String?, gender: String?, socmed: [SocialMedia]?)
    case story
    case deleteMyAccount(passwordd: String, reason: String)
}

extension ProfileEndpoint: EndpointType {
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .unfollowAccount(let id):
			return "/profile/\(id)/unfollow"
		case .followAccount(let id):
			return "/profile/\(id)/follow"
		case .profile(let id):
			return "/profile/\(id)"
		case .postAccount(let id, let type, _):
			return "/feeds/post/\(type)/profile/\(id)"
		case .followers(let id):
			return "/profile/\(id)/count/followers"
		case .searchFollowers(let id, _,_):
			return "/profile/\(id)/followers/search"
		case .searchFollowing(let id, _,_):
			return "/profile/\(id)/following/search"
		case .listFollowers(let id, _):
			return "/profile/\(id)/followers"
		case .listFollowings(let id, _):
			return "/profile/\(id)/following"
		case .followings(let id):
			return "/profile/\(id)/count/following"
			case .totalPost(let id):
				return "/profile/\(id)/count/posts"
		case .followChannel(let id):
			return "/channels/\(id)/follow"
		case .unfollowChannel(let id):
			return "/channels/\(id)/unfollow"
		case .updateAccount(let id, _, _, _, _,_, _):
			return "/profile/\(id)"
		case .profileUsername(let username):
			return "/profile/username"
        case .story:
            return "/stories?page=0&direction=DESC&size=1"
        case .deleteMyAccount(_, _):
            return "/profile/me"

		}
	}
	
	var method: HTTPMethod {
		switch self {
		case .followAccount(_), .unfollowAccount(_), .followChannel(_), .unfollowChannel(_):
			return .patch
        case .updateAccount:
            return .put
        case .deleteMyAccount(_, _):
            return .delete
		default:
			return .get
		}
	}
	
	var header: [String : String]  {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type" : "application/json"
		]
	}


    var body: [String: Any] {
        switch self {
        case let .updateAccount(_, bio, name, photo, birthDate, gender, _):
            return [
                "bio": bio,
                "name" : name,
                "photo" : photo,
                "birthDate" : birthDate,
                "gender" : gender
            ]
        case .deleteMyAccount(let password, let reason):
            return [
                "password": password,
                "reasonDeleted" : reason
            ]
        default: return [:]
        }
    }
	
	var parameter: [String : Any] {
		switch self {
		case .postAccount(_,_, let page), .listFollowers(_, let page), .listFollowings(_, let page):
			return [
				"page" : "\(page)",
			]
		case let .searchFollowers(_, name, page), let .searchFollowing(_, name, page) :
			return [
				"name" : name,
				"page" : "\(page)"
			]
	 case .profileUsername(let text), .profile(let text):
			return [
				"value" : "\(text)",
			]
		default:
			return [:]
		}
	}
	
}
