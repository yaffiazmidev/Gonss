import Foundation
import KipasKipasNetworking
import KipasKipasShared
import KipasKipasDirectMessage

public final class SetDiamondsReceivedUIFactory {
	
	private init() {}
	
	public static func create(accountId: String) -> SetDiamondsReceivedViewController {
		let setDiamondLoader = RemoteSetDiamondsReceivedLoader(url: SetDiamondsReceivedUIFactory.baseURL, client: SetDiamondsReceivedUIFactory.authenticatedHTTPClient)
		let lastDiamondLoader = RemoteLastDiamondLoader(url: SetDiamondsReceivedUIFactory.baseURL, client: SetDiamondsReceivedUIFactory.authenticatedHTTPClient)
		
		let controller = SetDiamondsReceivedUIComposer.setDiamondsReceivedComposeWith(
			accountId: accountId,
			loader: setDiamondLoader,
			lastDiamondLoader: lastDiamondLoader
		)
		
		return controller
	}
	
	public static func makeHTTPClient(baseURL: URL) -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
		let httpClient = URLSessionHTTPClient(session: URLSession(configuration: configuration))
		let localTokenLoader = LocalTokenLoader(store: tokenStore)
		let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
		let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
		let tokenLoader = TokenLoaderWithFallbackComposite(primary: localTokenLoader, fallback: fallbackTokenLoader)
		
		let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: tokenStore, loader: tokenLoader)
		
		return (httpClient, authHTTPClient)
	}
	
	static private func makeKeychainTokenStore() -> TokenStore {
		return KeychainTokenStore()
	}
	
	private static var tokenStore: TokenStore = {
		return SetDiamondsReceivedUIFactory.makeKeychainTokenStore()
	}()
	
	private static var authenticatedHTTPClient: HTTPClient = {
		return makeHTTPClient(baseURL: baseURL).authHTTPClient
	}()
	
	private static var baseURL: URL = {
		return URL(string: APIConstants.shared.baseUrl)!
	}()
}
