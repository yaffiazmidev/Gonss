import Foundation

public class RemoteTokenLoader: TokenLoader {
    private let url : URL
    private let client: HTTPClient
    
    public var needAuth: (() -> Void)?
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public typealias Result = TokenLoader.Result
    
    public func load(request: TokenRequest) async throws -> TokenItem {
        let request = URLRequest(url: enrich(url, with: request))
        
        do {
            let (data, response) = try await client.request(from: request)
            let items = try TokenItemMapper.map(data, from: response)
            return items.toModel()
        } catch {
            needAuth?()
            throw error
        }
    }
}

private extension RemoteTokenLoader {
    
    func enrich(_ url: URL, with request: TokenRequest) -> URL {
        var urlComponents = URLComponents(url: url.appendingPathComponent("auth/refresh_token"), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "is_new", value: "true"),
            URLQueryItem(name: "refresh_token", value: request.refresh_token),
            URLQueryItem(name: "grant_type", value: "\(request.grant_type)")
        ]
        return urlComponents?.url ?? url
    }
}

private extension RemoteTokenItem {
    private var expiredInOneDay: Int {
        return 86400
    }
    
    func toModel() -> TokenItem {
        let expiredDate = TokenHelper.addSecondToCurrentDate(second: expiresIn ?? expiredInOneDay)
        return TokenItem(
            accessToken: accessToken ?? "",
            refreshToken: refreshToken ?? "",
            expiresIn: expiredDate
        )
    }
}
