import Foundation

final class ImageHTTPClientFactory {
    
    static func create(
        with configuration: URLSessionConfiguration = ImageURLSessionConfiguration.default
    ) -> ImageHTTPClient {
        
        let session = ImageURLSession.createSession(with: configuration)
        let httpClient = URLSessionHTTPClient(session: session)
        
        guard let cache = ImageDownloadSettings.requestSettings.cacheSettings else {
            return httpClient
        }
        
        return CachedHTTPClientDecorator(
            expirationTime: cache.cacheExpirationTime,
            session: session,
            decoratee: httpClient
        )
    }
}
