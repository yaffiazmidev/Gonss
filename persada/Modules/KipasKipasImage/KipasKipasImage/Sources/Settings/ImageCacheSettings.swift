import Foundation

/**
 Specify settings for caching of downloaded images.
 */
public struct ImageCacheSettings: Equatable {
    
    public enum Size: Equatable {
        case megabyte(Int)
        
        public static func ==(lhs: Size, rhs: Size) -> Bool {
            switch (lhs, rhs) {
            case let (.megabyte(lhsSize), .megabyte(rhsSize)):
                return lhsSize == rhsSize
            }
        }
        
        var value: Int {
            switch self {
            case let .megabyte(size):
                return size * 1024 * 1024
            }
        }
    }
    
    /// The memory capacity of the cache, in bytes. Default value is 20 MB.
    public var memoryCapacityBytes: Size = .megabyte(20)
    
    /// The disk capacity of the cache, in bytes. Default value is 100 MB.
    public var diskCapacityBytes: Size = .megabyte(100)
    
    /**
     
     The caching policy for the image downloads. The default value is .useProtocolCachePolicy.
     
     * .useProtocolCachePolicy - Images are cached according to the the response HTTP headers, such as age and expiration date. This is the default cache policy.
     * .reloadIgnoringLocalCacheData - Do not cache images locally. Always downloads the image from the source.
     * .returnCacheDataElseLoad - Loads the image from local cache regardless of age and expiration date. If there is no existing image in the cache, the image is loaded from the source.
     * .returnCacheDataDontLoad - Load the image from local cache only and do not attempt to load from the source.
     
     */
    public var requestCachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy
    
    /**
     The cache expiration time (in seconds). If expired should return from remote data.
     If zero (0), the data won't return from cache
     */
    public var cacheExpirationTime: TimeInterval = 0
    
    /**
     The name of a subdirectory of the application’s default cache directory
     in which to store the on-disk cache.
     */
    public var diskPath = "kkImageCache"
    
    public init() {}
}

public func ==(lhs: ImageCacheSettings, rhs: ImageCacheSettings) -> Bool {
    return lhs.memoryCapacityBytes == rhs.memoryCapacityBytes
    && lhs.diskCapacityBytes == rhs.diskCapacityBytes
    && lhs.requestCachePolicy == rhs.requestCachePolicy
    && lhs.diskPath == rhs.diskPath
    && lhs.cacheExpirationTime == rhs.cacheExpirationTime
}

func !=(lhs: ImageCacheSettings, rhs: ImageCacheSettings) -> Bool {
    return !(lhs == rhs)
}

