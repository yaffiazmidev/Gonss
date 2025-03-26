import Foundation
import KipasKipasNetworking

public class RemoteNotificationFollowUserLoader: NotificationFollowUserLoader {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationFollowUserLoader.ResultFollowUser
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func load(request: NotificationFollowUserRequest, completion: @escaping (ResultFollowUser) -> Void) {
        let request = NotificationEndpoint.followUser(request: request).url(baseURL: url)
        
        Task {
            do {
                let (_, _) = try await client.request(from: request)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
