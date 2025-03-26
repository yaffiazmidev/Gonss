import Foundation

public struct StoryPaging<Response: Codable>: Codable {
    public var content: Response
    public let pageable: StoryPagingPagable
    public let totalPages: Int
    public let totalElements: Int
    public let last: Bool
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let sort: StoryPagingSort
    public let first: Bool
    public let empty: Bool
    
    public init(content: Response, pageable: StoryPagingPagable, totalPages: Int, totalElements: Int, last: Bool, number: Int, size: Int, numberOfElements: Int, sort: StoryPagingSort, first: Bool, empty: Bool) {
        self.content = content
        self.pageable = pageable
        self.totalPages = totalPages
        self.totalElements = totalElements
        self.last = last
        self.number = number
        self.size = size
        self.numberOfElements = numberOfElements
        self.sort = sort
        self.first = first
        self.empty = empty
    }
}

public struct StoryPagingPagable: Codable {
    public let offsetPage: Int?
    public let sort: StoryPagingSort
    public let startId: String?
    public let nocache: Bool?
    public let pageNumber: Int
    public let pageSize: Int
    public let offset: Int
    public let paged: Bool
    public let unpaged: Bool
    
    public init(offsetPage: Int?, sort: StoryPagingSort, startId: String?, nocache: Bool?, pageNumber: Int, pageSize: Int, offset: Int, paged: Bool, unpaged: Bool) {
        self.offsetPage = offsetPage
        self.sort = sort
        self.startId = startId
        self.nocache = nocache
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.offset = offset
        self.paged = paged
        self.unpaged = unpaged
    }
}

public struct StoryPagingSort: Codable {
    public let sorted: Bool
    public let unsorted: Bool
    public let empty: Bool
    
    public init(sorted: Bool, unsorted: Bool, empty: Bool) {
        self.sorted = sorted
        self.unsorted = unsorted
        self.empty = empty
    }
}
