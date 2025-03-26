//
//  RemoteChannel.swift
//
//  Created by DENAZMI on 07/03/22
//  Copyright (c) Koanba. All rights reserved.
//

import Foundation

struct RemoteChannel: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case data
    case message
  }

  var code: String?
  var data: RemoteChannelData?
  var message: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    data = try container.decodeIfPresent(RemoteChannelData.self, forKey: .data)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }

}

struct RemoteChannelContent: Codable {

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



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    photo = try container.decodeIfPresent(String.self, forKey: .photo)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    isFollow = try container.decodeIfPresent(Bool.self, forKey: .isFollow)
  }

}

struct RemoteChannelData: Codable {

  enum CodingKeys: String, CodingKey {
    case numberOfElements
    case last
    case sort
    case first
    case totalElements
    case pageable
    case content
    case totalPages
    case number
    case size
    case empty
  }

  var numberOfElements: Int?
  var last: Bool?
  var sort: RemoteChannelSort?
  var first: Bool?
  var totalElements: Int?
  var pageable: RemoteChannelPageable?
  var content: [RemoteChannelContent]?
  var totalPages: Int?
  var number: Int?
  var size: Int?
  var empty: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    sort = try container.decodeIfPresent(RemoteChannelSort.self, forKey: .sort)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
    pageable = try container.decodeIfPresent(RemoteChannelPageable.self, forKey: .pageable)
    content = try container.decodeIfPresent([RemoteChannelContent].self, forKey: .content)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}

struct RemoteChannelPageable: Codable {

  enum CodingKeys: String, CodingKey {
    case offset
    case pageNumber
    case pageSize
    case paged
    case sort
    case unpaged
  }

  var offset: Int?
  var pageNumber: Int?
  var pageSize: Int?
  var paged: Bool?
  var sort: RemoteChannelSort?
  var unpaged: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    offset = try container.decodeIfPresent(Int.self, forKey: .offset)
    pageNumber = try container.decodeIfPresent(Int.self, forKey: .pageNumber)
    pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize)
    paged = try container.decodeIfPresent(Bool.self, forKey: .paged)
    sort = try container.decodeIfPresent(RemoteChannelSort.self, forKey: .sort)
    unpaged = try container.decodeIfPresent(Bool.self, forKey: .unpaged)
  }

}

struct RemoteChannelSort: Codable {

  enum CodingKeys: String, CodingKey {
    case sorted
    case unsorted
    case empty
  }

  var sorted: Bool?
  var unsorted: Bool?
  var empty: Bool?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sorted = try container.decodeIfPresent(Bool.self, forKey: .sorted)
    unsorted = try container.decodeIfPresent(Bool.self, forKey: .unsorted)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
  }

}
