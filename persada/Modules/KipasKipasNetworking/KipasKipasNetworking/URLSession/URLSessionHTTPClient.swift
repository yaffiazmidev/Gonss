import Foundation
import KipasKipasShared

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation : Error {}
    
    public func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        
        if Task.isCancelled {
            try Task.checkCancellation()
        }
        
        let task = Task {
            do {
                let (data, response) = try await session.data(for: enrich(request))
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw UnexpectedValuesRepresentation()
                }
                
                return (data, httpResponse)
                
            } catch {
                let err = error as NSError
                if err.domain == "NSURLErrorDomain" && errorCodeList.contains(err.code)  {
                    NotificationCenter.default.post(name: .init("NSURLErrorDomain"), object: request.url?.absoluteString)
                }
                throw error
            }
        }
        
        return try await withTaskCancellationHandler {
            try await task.value
        } onCancel: {
            task.cancel()
        }
    }
    
    private let errorCodeList: [Int] = [
        -1004, -1005, -1023, -1024, -1025, -1026, -1027
    ]
}

private extension URLSessionHTTPClient {
    func enrich(_ request: URLRequest) -> URLRequest {
        var request = request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let env = KKRuntimeEnvironment.instance.type.code
            let value = "\(env)-\(version)"
            request.setValue(value, forHTTPHeaderField: "X-KK-BuildVersion")
        }
        
        return request
    }
}
