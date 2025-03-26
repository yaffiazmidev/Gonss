import Foundation

public enum GlobalRankEndpoint {
    case getGlobalRank(_ request: DonationGlobalRankRequest)
    case getSelfGlobalRank(accountId: String)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .getGlobalRank(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/donations/rank/global"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .getSelfGlobalRank(accountId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/donations/rank/global/\(accountId)"
            
            return URLRequest(url: components.url!)
        }
    }
}
