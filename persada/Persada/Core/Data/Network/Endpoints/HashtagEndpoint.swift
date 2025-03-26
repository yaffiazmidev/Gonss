//
//  HashtagEndpoint.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 09/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum HashtagEndpoint {
    case getHashtagList(hashtag: String, page: Int, size: Int)
    case getHashtagPostList(hashtag: String, page: Int, size: Int)
}

extension HashtagEndpoint : EndpointType {
	
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .getHashtagList:
			return "/feeds/search/hashtag"
		case .getHashtagPostList:
			return "/search/feeds/post/hashtag"
		}
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var header: [String : Any] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type" : "application/json",
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case let .getHashtagList(hashtag, page, size), let .getHashtagPostList(hashtag, page, size):
			return [
				"value" : "\(hashtag)",
				"size" : "\(size)",
				"page" : "\(page)",
                "sort" : "id"
			]
		}
	}
}
