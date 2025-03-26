import Foundation

final class CachedHTTPClientDecorator: ImageHTTPClient {
    
    private let expirationTime: TimeInterval
    private let session: URLSession
    private let decoratee: ImageHTTPClient
    
    init(
        expirationTime: TimeInterval,
        session: URLSession,
        decoratee: ImageHTTPClient
    ) {
        self.expirationTime = expirationTime
        self.session = session
        self.decoratee = decoratee
    }
    
    func request(from request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            // Check if the cached response is still valid
            if let cachedResponse = cached(for: request) {
                return cachedResponse
            }
            
            let (data, response) = try await decoratee.request(from: request)
            let cache = CachedURLResponse(response: response as URLResponse, data: data)
            URLCache.shared.storeCachedResponse(cache, for: request)
            
            return (data, response)
            
        } catch {
            throw error
        }
    }
    
    private func cached(for request: URLRequest) -> (Data, HTTPURLResponse)? {
        guard let cachedResponse = session.configuration.urlCache?.cachedResponse(for: request),
              let httpResponse = cachedResponse.response as? HTTPURLResponse else {
            return nil
        }
        
        guard let serverDateString = httpResponse.allHeaderFields["Date"] as? String,
              let serverDate = DateFormatter.httpHeaderFormatter.date(from: serverDateString) else {
           return nil
        }
        
        let endDate = serverDate.addingTimeInterval(expirationTime)
        
        guard endDate >= Date() else {
            session.configuration.urlCache?.removeCachedResponse(for: request)
            return nil
        }
        
        return (cachedResponse.data, httpResponse)
    }
}

extension DateFormatter {
    static var httpHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
