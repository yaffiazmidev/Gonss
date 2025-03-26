import Combine

public struct RootData<Response: Codable>: Codable {
    public let code, message: String
    public let data: Response
    
    public init(code: String, message: String, data: Response) {
        self.code = code
        self.message = message
        self.data = data
    }
}

public struct EmptyData: Codable {
    public let code, message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

// MARK: - List
public typealias StoryListResponse = RootData<StoryData>
public typealias StoryListLoader = AnyPublisher<RootData<StoryData>, Error>

// MARK: - Viewers
public typealias StoryViewersResponse = RootData<StoryPaging<[StoryViewer]>>

// MARK: - Upload/Create
public typealias StoryUploadResponse = EmptyData
public typealias StoryUploader = AnyPublisher<EmptyData, Error>
