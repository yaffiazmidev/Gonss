import Foundation
import KipasKipasNetworking

public final class RemoteReportReasonLoader: ReportReasonLoader {
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidResponse
        case notAuthenticated
    }
    
    public typealias Result = ReportReasonLoader.Result
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func fetch(_ reportType: ReportKind, completion: @escaping (Result) -> Void) {
        let request = URLRequest(url: enrich(baseURL, with: reportType))
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                completion(RemoteReportReasonLoader.map(data, from: response))
            } catch {
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension RemoteReportReasonLoader {
    func enrich(_ url: URL, with type: ReportKind) -> URL {
        let requestURL = url
            .appendingPathComponent("reports")
            .appendingPathComponent("reason")
            .appendingPathComponent(type.rawValue)
        
        return requestURL
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try RemoteReasonDataMapper.map(data, from: response)
            return .success(items.asPageDTO)
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteReasonData.Reason {
    var reason: String? {
        return type == "OTHERS" ? "Alasan lainnya" : value
    }
}

private extension RemoteReasonData {
    var asPageDTO: ReportReasonResponse {
        let reasons = data?.compactMap { item in
            return ReportReason(
                id: item.id ?? "",
                type: item.type ?? "",
                value: item.reason ?? ""
            )
        } ?? []
        return .init(reasons: reasons)
    }
}
