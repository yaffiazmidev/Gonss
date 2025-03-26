import Foundation

public struct LiveRoomSummaryRequest: Codable {
    public let totalDuration: Int
    public let totalLike: Int
    public let totalAudience: Int
    public let streamingId: String
    
    public init(totalDuration: Int, totalLike: Int, totalAudience: Int, streamingId: String) {
        self.totalDuration = totalDuration
        self.totalLike = totalLike
        self.totalAudience = totalAudience
        self.streamingId = streamingId
    }
}

public enum LiveStreamEndpoint {
    case validation
    case activeLiveStreamList
    case create(roomId: String, roomName: String)
    case dismissRoom(_ request: LiveRoomSummaryRequest)
    case dailyRank
    case popularLive
    case gifts
    case coinBalance
    case topSeat(roomId: String)
    case topViewers(roomId: String)
    
    private struct LiveRoom: Codable {
        let description: String
    }
    
    public enum ValidationError: Error {
        case general
        case insufficientFollowers
    }
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case .validation:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/validation"
            
            return URLRequest(url: components.url!)
            
        case let .create(roomId, roomName):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/\(roomId)/active"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(LiveRoom(description: roomName))
            
            return urlRequest
            
        case .activeLiveStreamList:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/active"
            
            return URLRequest(url: components.url!)
            
        case let .dismissRoom(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/inactive"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try? JSONEncoder().encode(request)
            
            return urlRequest
            
        case .dailyRank:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/rank/daily"
            
            return URLRequest(url: components.url!)
        case .popularLive:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/rank/host"
            
            return URLRequest(url: components.url!)
            
        case .gifts:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/gifts"
            return URLRequest(url: components.url!)
            
        case .coinBalance:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/balance/currency"
            
            components.queryItems = [
                URLQueryItem(name: "currencyType", value: "COIN"),
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .topSeat(roomId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/top-seats"
            
            components.queryItems = [
                URLQueryItem(name: "roomId", value: roomId),
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
            
        case let .topViewers(roomId):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/live-stream/viewers"
            
            components.queryItems = [
                URLQueryItem(name: "roomId", value: roomId),
            ].compactMap { $0 }
            
            return URLRequest(url: components.url!)
        }
    }
}
