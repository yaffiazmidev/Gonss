import Foundation

public protocol ImageHTTPClientTask {
    func cancel()
}

public protocol ImageHTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
