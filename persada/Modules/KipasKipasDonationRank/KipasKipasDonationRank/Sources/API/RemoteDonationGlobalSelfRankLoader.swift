import Foundation
import KipasKipasNetworking

public final class RemoteDonationGlobalSelfRankLoader: DonationGlobalSelfRankLoader {
    
    public typealias Result = DonationGlobalSelfRankLoader.Result
    
    public let baseURL: URL
    public let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func loadSelfRank(accountId: String, completion: @escaping (Result) -> Void) {
        let url = GlobalRankEndpoint.getSelfGlobalRank(accountId: accountId).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: url)
                completion(RemoteDonationGlobalSelfRankLoader.map(data, from: response))
            } catch {
                completion(.success(.dummy))
            }
        }
    }
}

private extension RemoteDonationGlobalSelfRankLoader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<Root<RemoteDonationGlobalRank>>.map(data, from: response)
            return .success(response.data.asItem)
        } catch {
            return .success(.dummy)
        }
    }
}

private extension DonationGlobalRankItem {
    static var dummy: Self {
        return RemoteDonationGlobalRank(
            id: nil,
            globalRank: nil,
            name: nil,
            statusRank: nil,
            url: nil,
            account: nil
        ).asItem
    }
}
