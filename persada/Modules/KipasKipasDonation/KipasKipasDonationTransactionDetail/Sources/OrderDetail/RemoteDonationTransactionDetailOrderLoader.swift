import Foundation
import KipasKipasNetworking

public class RemoteDonationTransactionDetailOrderLoader: DonationTransactionDetailOrderLoader {
    private let url : URL
    private let client: HTTPClient
  
    public typealias Result = DonationTransactionDetailOrderLoader.DonationTransactionDetailResult
    
    public init(baseURL: URL, client: HTTPClient) {
        self.url = baseURL
        self.client = client
    }
    
    public func load(request: DonationTransactionDetailOrderRequest, completion: @escaping (Result) -> Void) {
        let request = DonationTransactionDetailEndpoint.detail(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteDonationTransactionDetailOrderLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let data = try DonationTransactionDetailOrderItemMapper.map(data, from: response)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}
