import Foundation

enum ListBadgeEndpoint {
    case getListBadge
    case updateBadge(_ isShowBadge: Bool)
    
    private struct Patch: Encodable {
        let isShowBadge: Bool
    }
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case .getListBadge:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/donations/badge"
            
            return URLRequest(url: components.url!)
            
        case let .updateBadge(isShowbadge):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/donations/badge"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PATCH"
            request.httpBody = try? JSONEncoder().encode(Patch(isShowBadge: isShowbadge))
            
            return request
        }
    }
}
