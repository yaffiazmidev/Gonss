//
//  UploadEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Alamofire

enum UploadEndpoint {
	case upload
	case uploadMedia(imagePath: String, ratio: String)
    case postSocial
	case postProduct
	case createStory
}

extension UploadEndpoint: EndpointType {
	
	var baseUrl: URL {
		switch self {
		case .uploadMedia, .upload:
			return URL(string: APIConstants.uploadURL)!
		default:
			return URL(string: APIConstants.baseURL)!
		}
		
	}
	
	var path: String {
		switch self {
		case .upload:
			return "/accounts"
		case .postSocial:
			return "/feeds/post/social"
		case .postProduct:
			return "/products"
		case .createStory:
			return "/stories"
		case .uploadMedia:
			return "/medias"
		}
	}
	
	var method: HTTPMethod {
		return .post
	}
	
	var body: [String: Any] {
		return [:]
	}
	
	var headers: HTTPHeaders {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-type": "multipart/form-data",
			"Accept": "application/json"
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case .uploadMedia(let imagePath, let ratio):
			return [
				"ratio" : ratio,
				"path": imagePath,
			]
		default:
			return [:]
		}
	}
	
}


// MARK: - PostSocialParameter
struct PostSocialParameter: Codable {
	var typePost: String?
	var post: PostParameters?
	
	enum CodingKeys: String, CodingKey {
		case post = "post"
		case typePost = "typePost"
	}
	
}

// MARK: - PostParameters
struct PostParameters: Codable {
	var postDescription, channelId: String?
	var media: [MediaParameter]?
	
	enum CodingKeys: String, CodingKey {
		case channelId = "channelId"
		case postDescription = "description"
		case media = "media"
	}
	
}

// MARK: - Media
struct MediaParameter: Codable {
	var type: String?
	var url, thumbnail: String?
	var metadata: Metadata?
	
	enum CodingKeys: String, CodingKey {
		case metadata = "metadata"
		case thumbnail = "thumbnail"
		case type = "type"
		case url = "url"
	}
	
}
