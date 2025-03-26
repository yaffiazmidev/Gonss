import Foundation

enum DonationTransactionDetailEndpoint {
    case detail(request: DonationTransactionDetailOrderRequest)
    case group(request: DonationTransactionDetailGroupRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .detail(request):
            var url = baseURL
            url.appendPathComponent("orders")
            url.appendPathComponent(request.id)
            
            return URLRequest(url: url)
        case let .group(request):
            var url = baseURL
            url.appendPathComponent("orders")
            url.appendPathComponent("donation")
            url.appendPathComponent("group")
            url.appendPathComponent(request.groupId)
            
            return URLRequest(url: url)
        }
    }
}
