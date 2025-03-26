import Foundation

public struct DonationHistoryRequest {
    public let size: Int
    public let page: Int
    public let type: String
    public let campaignId: String
    
    public init(
        size: Int = 25,
        page: Int,
        type: String,
        campaignId: String
    ) {
        self.size = size
        self.page = page
        self.type = type
        self.campaignId = campaignId
    }
}

public enum DonationHistoryEndpoint {
    case donorHistory(request: DonationHistoryRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .donorHistory(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/balance/donations/\(request.campaignId)/history"
            
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(request.page)"),
                URLQueryItem(name: "size", value: "\(request.size)"),
                URLQueryItem(name: "type", value: request.type)
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
        }
    }
}
