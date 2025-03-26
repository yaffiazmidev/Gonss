import Foundation
import KipasKipasNetworking

public final class RemoteListBadgeLoader: ListBadgeLoader {
    
    public typealias Result = ListBadgeLoader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func loadBadge(completion: @escaping (Result) -> Void) {
        let request = ListBadgeEndpoint.getListBadge.url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteListBadgeLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
    
    public func updateBadge(isShowBadge: Bool, completion: @escaping (Error?) -> Void) {
        let request = ListBadgeEndpoint.updateBadge(isShowBadge).url(baseURL: baseURL)
        
        Task {
            do {
                let (_, response) = try await client.request(from: request)
                if (200...299).contains(response.statusCode) {
                    completion(nil)
                }
            } catch {
                completion(KKNetworkError.failed)
            }
        }
    }
}

private extension RemoteListBadgeLoader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<Root<[Badge]>>.map(data, from: response)
            return .success(response.data)
        } catch {
            return .failure(error)
        }
    }
}
