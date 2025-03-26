import Foundation
import KipasKipasNetworking

public enum ReportEndpoint {
    case submitReport(request: ReportSubmissionRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .submitReport(req):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/reports"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(req)
            
            return request
        }
    }
}

public final class RemoteReportSubmissionLoader: ReportSubmissionLoader {
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public typealias Result = ReportSubmissionLoader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func submit(_ req: ReportSubmissionRequest, completion: @escaping (Result) -> Void) {
        let url = ReportEndpoint.submitReport(request: req).url(baseURL: baseURL)
        
        Task {
            do {
                let _ = try await client.request(from: url)
                completion(.success(()))
            } catch {
                completion(.failure(Error.connectivity))
            }
        }
    }
}
