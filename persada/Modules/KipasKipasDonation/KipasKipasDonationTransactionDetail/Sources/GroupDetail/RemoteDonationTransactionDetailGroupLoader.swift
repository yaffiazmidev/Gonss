import Foundation
import KipasKipasNetworking

public class RemoteDonationTransactionDetailGroupLoader: DonationTransactionDetailGroupLoader {
    private let url : URL
    private let client: HTTPClient
  
    public typealias Result = DonationTransactionDetailGroupLoader.GroupResult
    
    public init(baseURL: URL, client: HTTPClient) {
        self.url = baseURL
        self.client = client
    }
    
    public func load(request: DonationTransactionDetailGroupRequest, completion: @escaping (Result) -> Void) {
        let request = DonationTransactionDetailEndpoint.group(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteDonationTransactionDetailGroupLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let data = try DonationTransactionDetailGroupItemMapper.map(data, from: response)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}
