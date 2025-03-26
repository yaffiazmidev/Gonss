import Foundation
import KipasKipasNetworking

public class RemoteVerifyIdentityCountryLoader: VerifyIdentityCountryLoader {
    
    public typealias Result = VerifyIdentityCountryLoader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        let request = enrich(baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteVerifyIdentityCountryLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension RemoteVerifyIdentityCountryLoader {
    private func enrich(_ baseURL: URL) -> URLRequest {
        return .url(baseURL)
            .path("/countries")
            .build()
    }
}

private extension RemoteVerifyIdentityCountryLoader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<Root<[VerifyIdentityCountryItem]>>.map(data, from: response)
            return .success(response.data)
        } catch {
            return .failure(error)
        }
    }
}
