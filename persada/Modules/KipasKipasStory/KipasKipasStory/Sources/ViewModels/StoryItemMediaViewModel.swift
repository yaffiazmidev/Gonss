import Foundation

public enum StoryItemType: String {
    case post
    case repost
}

public enum StoryItemMediaType: String {
    case image
    case video
    case none
}

public struct StoryItemMediaMetadata: Equatable {
    public let duration: Double
    
    public init(duration: Double) {
        self.duration = duration
    }
}

public struct StoryItemMediaViewModel: Equatable {
    public let id: String
    public let type: StoryItemMediaType
    public let url: String
    public let vodURL: String?
    public let thumbnail: String
    public let metadata: StoryItemMediaMetadata
    
    public init(
        id: String,
        type: StoryItemMediaType,
        url: String,
        vodURL: String?,
        thumbnail: String,
        metadata: StoryItemMediaMetadata
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.vodURL = vodURL
        self.thumbnail = thumbnail
        self.metadata = metadata
    }
}

public extension StoryItemMediaViewModel {
    var mediaURL: URL? {
        return URL(string: url)
    }
    
    var videoURL: URL? {
        guard let vodURL = vodURL else {
            return URL(string: url)
        }
        return URL(string: vodURL)
    }
    
    var thumbnailURL: URL? {
        return URL(string: thumbnail)
    }
}
