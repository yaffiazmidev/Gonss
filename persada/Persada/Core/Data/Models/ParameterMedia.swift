//
//  ParameterMedia.swift
//  Persada
//
//  Created by movan on 08/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct ParameterPostStory : Codable {
	
	let post : [MediaPostStory]?
	let typePost : String?
	
	enum CodingKeys: String, CodingKey {
		case post = "stories"
		case typePost = "typePost"
	}
}

struct MediaPostStory : Codable {
	
	let medias : [ResponseMedia]?
	let postProducts : [MediaPostProductId]?
	
	enum CodingKeys: String, CodingKey {
		case medias = "medias"
		case postProducts = "products"
	}
}

struct MediaPostProductId : Codable {
	
	let id : String?
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
	}}


struct ParameterPostProduct : Codable {

	let name : String?
	let description: String?
	let price: Int?
	let measurement: ProductMeasurement?
	let medias: [ResponseMedia]?
	let accountId: String?
	
	enum CodingKeys: String, CodingKey {
		case name, description, price, measurement, medias, accountId
	}
}

struct MediaPostProduct : Codable {
	
	let descriptionField : String?
	let channel: ChannelId?
	let measurement : ProductMeasurement?
	let medias : [ResponseMedia]?
	let name : String?
	let price : Int?
	let type : String?
	
	enum CodingKeys: String, CodingKey {
		case descriptionField = "description"
		case measurement = "measurement"
		case channel = "channel"
		case medias = "medias"
		case name = "name"
		case price = "price"
		case type = "type"
	}
}


struct ParameterPostSocial : Codable {
	
	let post : MediaPostSocial?
	let typePost : String?
	
	enum CodingKeys: String, CodingKey {
		case post = "post"
		case typePost = "typePost"
	}
}


struct MediaPostSocial : Codable {
	
	let channel : ChannelId?
	let descriptionField : String?
	let medias : [ResponseMedia]?
	let type : String?
	
	enum CodingKeys: String, CodingKey {
		case channel = "channel"
		case descriptionField = "description"
		case medias = "medias"
		case type = "type"
	}
}

struct ChannelId : Codable {
	
	let id : String?
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
	}
}
