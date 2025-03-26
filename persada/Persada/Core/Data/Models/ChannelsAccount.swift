//
//  ChannelsAccount.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


struct ParameterChannel: Codable {
	let id:String?
}

typealias Parameter = [ParameterChannel]

struct ChannelsAccount : Codable {
	
	let code : String?
	let data : [ChannelData]?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct ChannelData : Codable {
	
	let channels : Channel?
	let feeds : [Feed]?
	
	enum CodingKeys: String, CodingKey {
		case channels = "channels"
		case feeds = "feeds"
	}

}

struct ChannelResult : Codable {
	
	let code : String?
	let data : ChannelsData?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct ChannelsData: Codable {
	let content : [Channel]?
	let empty : Bool?
	let first : Bool?
	let last : Bool?
	let number : Int?
	let numberOfElements : Int?
	let pageable : Pageable?
	let size : Int?
	let sort : Sort?
	let totalElements : Int?
	let totalPages : Int?
	
	enum CodingKeys: String, CodingKey {
		case content = "content"
		case empty = "empty"
		case first = "first"
		case last = "last"
		case number = "number"
		case numberOfElements = "numberOfElements"
		case pageable = "pageable"
		case size = "size"
		case sort = "sort"
		case totalElements = "totalElements"
		case totalPages = "totalPages"
	}
}

struct Channel : Codable {
	
	var descriptionField : String?
	var id : String?
	var name : String?
	var photo : String?
	var isFollow: Bool?
    var code: String?
	
	enum CodingKeys: String, CodingKey {
		case descriptionField = "description"
		case id = "id"
		case name = "name"
		case photo = "photo"
		case isFollow = "isFollow"
        case code = "code"
	}
}

extension Channel: Hashable, Equatable {
	static func == (lhs: Channel, rhs: Channel) -> Bool {
		lhs.id == rhs.id
	}
}


struct ChannelDetail: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case data
    case message
  }

  var code: String?
  var data: ChannelDetailData?
  var message: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    data = try container.decodeIfPresent(ChannelDetailData.self, forKey: .data)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }

}

struct ChannelDetailData: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case name
    case id
    case createAt
    case photo
    case description
    case isFollow
  }

  var code: String?
  var name: String?
  var id: String?
  var createAt: Int?
  var photo: String?
  var description: String?
  var isFollow: Bool?
}
