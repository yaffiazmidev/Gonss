import Foundation
import KipasKipasNetworking

public struct DonationGlobalRankRequest {
    public let size: Int
    public let page: Int
    
    public init(size: Int = 100, page: Int) {
        self.size = size
        self.page = page
    }
}

public protocol DonationGlobalRankLoader {
    typealias Result = Swift.Result<[DonationGlobalRankItem], Error>
    func load(_ request: DonationGlobalRankRequest, completion: @escaping (Result) -> Void)
}
