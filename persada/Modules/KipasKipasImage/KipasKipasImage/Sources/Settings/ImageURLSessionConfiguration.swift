import Foundation

public struct ImageURLSessionConfiguration {
    public static var `default`: URLSessionConfiguration {
        let settings = ImageDownloadSettings.requestSettings
        
        var configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        
        if let cacheSettings = settings.cacheSettings {
            configuration = .default
            configuration.requestCachePolicy = cacheSettings.requestCachePolicy
            
            let cache = URLCache(
                memoryCapacity: cacheSettings.memoryCapacityBytes.value,
                diskCapacity: cacheSettings.diskCapacityBytes.value,
                diskPath: cacheSettings.diskPath
            )
            configuration.urlCache = cache
        }
        
        configuration.timeoutIntervalForRequest = settings.requestTimeoutSeconds
        configuration.timeoutIntervalForResource = settings.requestTimeoutSeconds
        configuration.httpMaximumConnectionsPerHost = settings.maximumSimultaneousDownloads
        
        return configuration
    }
}

