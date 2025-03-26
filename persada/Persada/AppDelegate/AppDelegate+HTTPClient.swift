import Foundation
import KipasKipasNetworking

extension AppDelegate {
    func makeHTTPClient(baseURL: URL) -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: configuration))
        let localTokenLoader = LocalTokenLoader(store: tokenStore)
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        remoteTokenLoader.needAuth = {
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        }
        
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: tokenStore, loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
}
