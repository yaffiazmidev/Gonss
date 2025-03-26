import Foundation

public enum StoryEndpoint {
    case list(request: StoryListRequest)
    case viewers(request: StoryViewerRequest)
    case upload(request: StoryUploadRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case .list(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/stories"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .viewers(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/stories/list-viewers"
            
            components.queryItems = [
                URLQueryItem(name: "storyId", value: "\(request.storyId)"),
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "GET"
            return urlRequest
        case .upload(let request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/stories"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(StoryUploadRootRequest(stories: [request]))
            return urlRequest
        }
    }
}

// MARK: - Data Story
public struct StoryListRequest {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int = 100) {
        self.page = page
        self.size = size
    }
}

// MARK: - Upload
public struct StoryUploadRootRequest: Codable {
    public let typePost: String
    public let stories: [StoryUploadRequest]
    
    init(typePost: String = "story", stories: [StoryUploadRequest]) {
        self.typePost = typePost
        self.stories = stories
    }
}

public enum StoryUploadType: String, Codable {
    case post = "post"
    case repost = "repost"
}

public struct StoryUploadRequest: Codable {
    public let feedIdRepost: String?
    public let usernameRepost: String?
    public let storyType: StoryUploadType
    public let medias: [StoryUploadMediaRequest]
    
    public init(feedIdRepost: String?, usernameRepost: String?, storyType: StoryUploadType, medias: [StoryUploadMediaRequest]) {
        self.feedIdRepost = feedIdRepost
        self.usernameRepost = usernameRepost
        self.storyType = storyType
        self.medias = medias
    }
}

public struct StoryUploadMediaRequest: Codable {
    public let isHlsReady: Bool
    public let type: String
    public let url: String
    public let thumbnail: StoryMediaThumbnailItem
    public let metadata: StoryMediaMetadataItem
    public let vodFileId: String
    
    public init(
        isHlsReady: Bool = false,
        type: String,
        url: String,
        thumbnail: StoryMediaThumbnailItem,
        metadata: StoryMediaMetadataItem,
        vodFileId: String
    ) {
        self.isHlsReady = isHlsReady
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.vodFileId = vodFileId
    }
}
