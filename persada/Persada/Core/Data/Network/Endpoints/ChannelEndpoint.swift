//
//  ChannelEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ChannelEndpoint {
	case channel
    case channelById(id: String)
	case channels(text: String, page: Int)
	case searchChannel(type: String,value: String, page: Int)
	case channelDetail(id: String, page: Int)
	case yourChannel(page: Int, size: Int)
	case publicSuggestionChannel(page: Int, size: Int)
	case suggestionChannel(page: Int, size: Int)
	case allSuggestionChannel(page: Int, size: Int)
	case publicExploreChannel(page: Int)
	case exploreChannel(page: Int)
	case search(text: String)
	case searchTop(text: String, page: Int)
	case searchHashtag(text: String)
	case searchContent(text: String)
	case channelGeneralPost(id: String, page: Int)
	case channelDetailById(id: String, page: Int)
	case followChannel(id: String)
	case unfollowChannel(id: String)
}

extension ChannelEndpoint: EndpointType {
	
	var method: HTTPMethod {
		switch self {
		case .followChannel(_), .unfollowChannel(_):
			return .patch
		default:
			return .get
		}
		
	}
	
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var body: [String : Any] {
		return [:]
	}
	
	var path: String {
		switch self {
		case .channels(_,_):
			return "/channels/search"
        case .channelById(let id):
            return "/channels/\(id)"
		case .channel:
			return "/channels/accounts"
		case .channelDetail(_,_):
			return "/feeds/search/channel"
		case .searchChannel(let value, _, _):
			return "/feeds/search/\(value)"
		case .yourChannel(_,_):
			return "/channels/me/follow"
		case .publicSuggestionChannel:
			return "/public/channels/for-you/posts/all"
		case .suggestionChannel(_,_):
			return "/channels/me/not-follow"
		case .allSuggestionChannel(_,_):
			return "/channels/me/not-follow/all"
		case .publicExploreChannel:
			return "/public/channels/general/posts"
		case .exploreChannel(_):
			return "/channels/general/posts"
		case .search(_):
			return "/search/account/username"
		case .searchTop(_,_):
			return "/search/top"
		case .searchHashtag(_):
			return "/search/feed/hashtag"
		case .searchContent(_):
			return "/search/feed/channel"
		case .channelGeneralPost(id: let id, _):
			return "/channels/general/posts/\(id)"
		case .channelDetailById(id: let id, _):
			return "feeds/channel/\(id)"
		case .followChannel(let id):
			return "/channels/\(id)/follow"
		case .unfollowChannel(let id):
			return "/channels/\(id)/unfollow"
		}
	}
	
	var header: [String : String]  {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type" : "application/json"
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case .channels(let text, let page):
			return [
				"page" : "\(page)",
				"name" : "\(text)"
			]
		case .channel:
			return [
				"page" : "0",
				"direction": "DESC",
				"sort": "id"
			]
		case .channelDetail(let id, let page):
			return [
				"value" : id,
				"page" : "\(page)"
			]
		case .searchChannel(_, let value, let page):
			return [
				"page" : "\(page)",
				"direction": "DESC",
				"sort": "id",
				"value" : "\(value)"
			]
		case .search(let text), .searchHashtag(let text):
			return [
				"value" : "\(text)"
			]
		case .yourChannel(let page, let size) , .suggestionChannel(let page, let size), .allSuggestionChannel(let page, let size), .publicSuggestionChannel(let page, let size):
			return [
				"page" : "\(page)",
				"size": "\(size)",
				"sort" : "createAt,desc"
			]
		case .exploreChannel(let page), .publicExploreChannel(let page):
			return [
				"page" : "\(page)",
				"size": "10",
				"sort" : "createAt,desc"
			]
		case .searchTop(let text, let page)  :
			return [
				"page" : "\(page)",
				"value" : "\(text)",
				"size": "6",
				"sort" : "createAt,desc"
			]
		case .searchContent(let text):
			return [
				"value" : "\(text)",
				"feedSize": "4"
			]
		case .channelGeneralPost(_, let page), .channelDetailById(_, let page):
			return [
				"page" : "\(page)"
			]
		default:
			return [:]
		}
	}
}
