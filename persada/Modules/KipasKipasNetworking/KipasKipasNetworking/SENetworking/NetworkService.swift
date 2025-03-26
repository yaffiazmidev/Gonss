//
//  NetworkService.swift
//  App
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

public protocol NetworkCancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }

public protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable?
}

public protocol NetworkSessionManager {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}

public protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

// MARK: - Implementation

internal final class DefaultNetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    internal init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger()) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
    
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                    print("STATUS CODE: \(response.statusCode)")
                } else {
                    print("STATUS CODE: \(404)")
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(.generic(NSError(domain: "Response not found..", code: 404))))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.error(statusCode: response.statusCode, data: data)))
                    return
                }
                
                guard response.statusCode == 200 else {
                    completion(.failure(.error(statusCode: response.statusCode, data: data)))
                    return
                }
                
                print("STATUS CODE: \(response.statusCode)")
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
    
        logger.log(request: request)

        return sessionDataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    
    public func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}

// MARK: - Default Network Session Manager
// Note: If authorization is needed NetworkSessionManager can be implemented by using,
// for example, Alamofire SessionManager with its RequestAdapter and RequestRetrier.
// And it can be incjected into NetworkService instead of default one.

public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        let task = URLSession(configuration: configuration).dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

// MARK: - Logger

public final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    public init() { }

    public func log(request: URLRequest) {
        var urlRequest = request
        print("========================================================================")
        print("REQUEST: \(urlRequest.url!)")
        print("METHOD : \(urlRequest.httpMethod!)")
        
        if let authorization = urlRequest.allHTTPHeaderFields?.filter({ $0.key == "Authorization" }).first {
            #if DEBUG || STAGING
            #else
            urlRequest.setValue("\(authorization.value.prefix(12))***\(authorization.value.suffix(6))", forHTTPHeaderField: "Authorization")
            #endif
        }
        
        print("HEADERS: \(urlRequest.allHTTPHeaderFields!)")
        
        if let httpBody = urlRequest.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            printIfDebug("BODY: \(String(describing: result))")
        } else if let httpBody = urlRequest.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("BODY: \(String(describing: resultString))")
        }
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("RESPONSE DATA: \(String(describing: dataDict))")
        }
    }

    public func log(error: Error) {
        printIfDebug("\(error)")
    }
}

// MARK: - NetworkError extension

extension NetworkError {
    public var isNotFoundError: Bool { return hasStatusCode(404) }
    
    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG || ProdDebug || STAGING
    print(string)
    #endif
}

extension DataTransferError {
    
    public var statusCode: Int {
        switch self {
        case .noResponse:
            return 404
        case .parsing(let error):
            let code = URLError.Code(rawValue: (error as NSError).code)
            return code.rawValue
        case .networkFailure(let networkError):
            switch networkError {
            case .error(let code, _):
                return code
            case .notConnected:
                return 500
            case .cancelled:
                return 499
            case .generic(let error):
                return 9999
            case .urlGeneration:
                return 12005
            }
        case .resolvedNetworkFailure(let error):
            let code = URLError.Code(rawValue: (error as NSError).code)
            return code.rawValue
        }
    }
    
    public var message: String? {
        switch self {
        case .noResponse:
            return "noResponse"
        case .parsing(let error):
            return "Error: \(error.localizedDescription)"
        case .networkFailure(let networkError):
            switch networkError {
            case .error(_, let data):
                guard let data = data else {
                    return "Error no data"
                }
                return String(data: data, encoding: .utf8)
            case .notConnected:
                return "notConnected"
            case .cancelled:
                return "cancelled"
            case .generic(let error):
                return "Error: \(error.localizedDescription)"
            case .urlGeneration:
                return "urlGeneration"
            }
        case .resolvedNetworkFailure(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
    
    public var data: Data? {
        switch self {
        case .networkFailure(let networkError):
            switch networkError {
            case .error(_, let data):
                return data
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
