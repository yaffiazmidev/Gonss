import Foundation
import UIKit

public extension URLRequest {
    struct Builder {
        
        public enum HTTPMethod: String {
            case GET
            case POST
            case UPDATE
            case DELETE
            case PATCH
        }
        
        private var components = URLComponents()
        private var method: HTTPMethod = .GET
        private var headers: [String: String] = [:]
        private var body: Data?
        
        private init() {}
        
        static func url(_ url: URL) -> Builder {
            var builder = Builder()
            builder.components.scheme = url.scheme
            builder.components.host = url.host
            builder.components.path = url.path
            return builder
        }
        
        public func method(_ method: HTTPMethod) -> Builder {
            var builder = self
            builder.method = method
            return builder
        }
        
        public func path(_ path: String) -> Builder {
            var builder = self
            builder.components.path += path
            builder.headers["model"] = UIDevice.modelName
            return builder
        }
        
        public func header(key: String, value: String) -> Builder {
            var builder = self
            builder.headers[key] = value
            return builder
        }
        
        public func body(_ param: Encodable) -> Builder {
            var builder = self
            builder.body = try? JSONEncoder().encode(param)
            return builder
        }
        
        public func queries(_ queries: [URLQueryItem]) -> Builder {
            var builder = self
            builder.components.queryItems = queries.compactMap { $0 }
            return builder
        }
        
        let modelName = UIDevice.modelName ;
        
        public func build() -> URLRequest {
            guard let url = components.url else {
                fatalError("URL is not set")
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            return request
        }
    }
    
    static func url(_ url: URL) -> Builder {
        return Builder.url(url)
    }
}

