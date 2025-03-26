//
//  NetworkService.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/02/22.
//  Copyright © 2022 Koanba. All rights reserved.
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
    typealias CompletionHandler = (Swift.Result<Data?, NetworkError>) -> Void
    
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

public final class DefaultNetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    private let refreshTokenManager: RefreshTokenManager
    
    public init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger(),
                refreshTokenManager: RefreshTokenManager = RefreshTokenService()) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
        self.refreshTokenManager = refreshTokenManager
    }
    
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let isPublicAPI = request.url?.absoluteString.contains("/public/") ?? false
        if AUTH.isTokenExpired() && !isPublicAPI {
            return refreshTokenManager.request(request: request, completion: completion)
        }
        
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            
            self.logger.log(request: request)
            self.logger.log(responseData: data, response: response)
            
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NetworkError.error(statusCode: 404, data: nil)
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = NetworkError.error(statusCode: 404, data: nil)
                completion(.failure(error))
                return
            }
            
            guard response.statusCode == 200 else {
                let error = NetworkError.error(statusCode: response.statusCode, data: data)
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
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

public final class KKDefaultNetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    public init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger()) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
    
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            
            self.logger.log(request: request)
            self.logger.log(responseData: data, response: response)
            
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NetworkError.error(statusCode: 404, data: nil)
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = NetworkError.error(statusCode: 404, data: nil)
                completion(.failure(error))
                return
            }
            
            guard response.statusCode == 200 else {
                let error = NetworkError.error(statusCode: response.statusCode, data: data)
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
        return sessionDataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet, .timedOut, .networkConnectionLost: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension KKDefaultNetworkService: NetworkService {
    
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
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 10.0
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

// MARK: - Logger

public final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    public init() { }

    public func log(request: URLRequest) {
        print("\n======================================================================")
        print("REQUEST : \(request.url!)")
        print("HEADERS : \(request.allHTTPHeaderFields!)")
        print("METHOD  : \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            printIfDebug("BODY    : \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("BODY    : \(String(describing: resultString))")
        }
        
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        if let response = response as? HTTPURLResponse {
            print("STATUS CODE : \(response.statusCode)")
            print("======================================================================")
        }
        
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            //printIfDebug("RESPONSE DATA: \(String(describing: dataDict))")
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
    
    var isRequestTimeOut: Bool {
        switch self {
        case .notConnected:
            return true
        default:
            return false
        }
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #elseif STAGING
    print(string)
    #endif
}
