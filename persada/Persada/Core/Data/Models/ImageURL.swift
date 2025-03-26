//
//  ImageURL.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - ImageURL
struct ImageURL: Codable {
	let code, message: String?
	let data: ResponseMedia?
}

// MARK: - ImageData
struct ResponseMedia: Codable {
	let id: String?
	let type: String?
	let url: String?
	let thumbnail: Thumbnail?
	let metadata: Metadata?
    let vodFileId: String?
    let vodUrl: String?
    
    init(id: String?, type: String?, url: String?, thumbnail: Thumbnail?, metadata: Metadata?, vodFileId: String? = nil, vodUrl: String? = nil) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.vodFileId = vodFileId
        self.vodUrl = vodUrl
    }
}

struct Thumbnail: Codable {
	
	var large: String?
	var medium: String?
	var small: String?
	
	enum CodingKeys: String, CodingKey {
		case large = "large"
		case medium = "medium"
		case small = "small"
	}
}

struct Metadata: Codable {
	let width: String?
	let height: String?
	let size: String?
    var duration: Double?
	
	enum CodingKeys: String, CodingKey {
		case height = "height"
		case size = "size"
		case width = "width"
        case duration
	}
}
