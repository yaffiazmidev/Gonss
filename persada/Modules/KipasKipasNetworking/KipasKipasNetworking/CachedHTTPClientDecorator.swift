import Foundation

public class CachedHTTPClientDecorator: HTTPClient {
    
    private let expirationTime: TimeInterval
    private let session: URLSession
    private let decoratee: HTTPClient
    
    public init(
        expirationTime: TimeInterval = 60.0,
        session: URLSession,
        decoratee: HTTPClient
    ) {
        self.expirationTime = expirationTime
        self.session = session
        self.decoratee = decoratee
    }
    
    public func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            // Check if the cached response is still valid
            if let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request),
               let httpResponse = cachedResponse.response as? HTTPURLResponse,
               isResponseValid(cachedResponse) {
                return (cachedResponse.data, httpResponse)
            }
            
            let (data, response) = try await decoratee.request(from: request)
            let cache = CachedURLResponse(response: response as URLResponse, data: data)
            
            URLCache.shared.storeCachedResponse(cache, for: request)
            
            return (data, response)
            
        } catch {
            throw error
        }
    }
    
    private func isResponseValid(_ response: CachedURLResponse) -> Bool {
        if let httpResponse = response.response as? HTTPURLResponse,
           let date = httpResponse.allHeaderFields["Date"] as? String,
           let serverDate = DateFormatter.httpHeaderFormatter.date(from: date),
           Date().timeIntervalSince(serverDate) < expirationTime {
            return true
        }
        return false
    }
}

private extension DateFormatter {
    static var httpHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

