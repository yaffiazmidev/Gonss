import Foundation
import KipasKipasNetworking


public final class RemoteDonationHistoryLoader: DonationHistoryLoader {
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public typealias Result = DonationHistoryLoader.Result
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load(request: DonationHistoryRequest, completion: @escaping (Result) -> Void) {
        let url = DonationHistoryEndpoint.donorHistory(request: request).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: url)
                completion(self.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let mapper = Mapper<Root<[RemoteDonationHistory]>>.self
            return .success(try mapper.map(data, from: response))
        } catch {
            return .failure(KKNetworkError.invalidData)
        }
    }
}
