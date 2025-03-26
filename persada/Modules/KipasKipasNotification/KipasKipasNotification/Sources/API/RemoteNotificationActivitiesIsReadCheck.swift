import Foundation
import KipasKipasNetworking

public class RemoteNotificationActivitiesIsReadCheck: NotificationActivitiesIsReadCheck {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationActivitiesIsReadCheck.ResultActivitiesIsRead
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func check(request: NotificationActivitiesIsReadRequest, completion: @escaping (Result) -> Void) {
        
        let request = NotificationEndpoint.activitiesIsRead(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteNotificationActivitiesIsReadCheck.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationActivitiesIsReadCheck.ResultActivitiesIsRead {
        do {
            let item = try NotificationActivitiesIsReadItemMapper.map(data, from: response)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationActivitiesIsReadItemMapper {
    
    private struct Root: Codable {
        private var code, message: String?
        
        var item: NotificationDefaultResponse {
            return NotificationDefaultResponse(code: code ?? "", message: message ?? "")
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationDefaultResponse {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
