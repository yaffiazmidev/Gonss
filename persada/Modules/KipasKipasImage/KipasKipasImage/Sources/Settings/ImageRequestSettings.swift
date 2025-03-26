import Foundation

public struct ImageRequestSettings: Equatable {
    
    /// Cache settings. If empty or nil the cache won't be used
    public var cacheSettings: ImageCacheSettings?
    
    /// Timeout for image requests in seconds. This will cause a timeout if a resource is not able to be retrieved within a given timeout. Default timeout: 10 seconds.
    public var requestTimeoutSeconds: Double = 10
    
    /// Maximum number of simultaneous image downloads. Default: 4.
    public var maximumSimultaneousDownloads: Int = 4
}

public func ==(lhs: ImageRequestSettings, rhs: ImageRequestSettings) -> Bool {
    return lhs.requestTimeoutSeconds == rhs.requestTimeoutSeconds
    && lhs.maximumSimultaneousDownloads == rhs.maximumSimultaneousDownloads
    && lhs.cacheSettings == rhs.cacheSettings
}

func !=(lhs: ImageRequestSettings, rhs: ImageRequestSettings) -> Bool {
    return !(lhs == rhs)
}
