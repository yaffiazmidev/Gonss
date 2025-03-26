import Foundation

public struct DirectMessageFollowing: Codable {

  enum CodingKeys: String, CodingKey {
    case pageable
    case last
    case number
    case content
    case empty
    case sort
    case first
    case totalPages
    case numberOfElements
    case size
    case totalElements
  }

    public var pageable: RemoteFollowingPageable?
    public var last: Bool?
    public var number: Int?
    public var content: [RemoteFollowingContent]?
    public var empty: Bool?
    public var sort: RemoteFollowingSort?
    public var first: Bool?
    public var totalPages: Int?
    public var numberOfElements: Int?
    public var size: Int?
    public var totalElements: Int?



  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    pageable = try container.decodeIfPresent(RemoteFollowingPageable.self, forKey: .pageable)
    last = try container.decodeIfPresent(Bool.self, forKey: .last)
    number = try container.decodeIfPresent(Int.self, forKey: .number)
    content = try container.decodeIfPresent([RemoteFollowingContent].self, forKey: .content)
    empty = try container.decodeIfPresent(Bool.self, forKey: .empty)
    sort = try container.decodeIfPresent(RemoteFollowingSort.self, forKey: .sort)
    first = try container.decodeIfPresent(Bool.self, forKey: .first)
    totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
    numberOfElements = try container.decodeIfPresent(Int.self, forKey: .numberOfElements)
    size = try container.decodeIfPresent(Int.self, forKey: .size)
    totalElements = try container.decodeIfPresent(Int.self, forKey: .totalElements)
  }

}
