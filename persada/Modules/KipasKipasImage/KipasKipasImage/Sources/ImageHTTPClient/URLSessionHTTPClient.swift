import Foundation

final class URLSessionHTTPClient: ImageHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation : Error {}
    
    func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        
        if Task.isCancelled {
            try Task.checkCancellation()
        }
        
        let task = Task {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw UnexpectedValuesRepresentation()
                }
                
                return (data, httpResponse)
                
            } catch {
                throw error
            }
        }
        
        return try await withTaskCancellationHandler {
            return try await task.value
        } onCancel: {
            task.cancel()
        }
    }
}

