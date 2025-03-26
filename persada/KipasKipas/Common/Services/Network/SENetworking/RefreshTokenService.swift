import Foundation
import FeedCleeps
import KipasKipasLogin

public protocol RefreshTokenManager {
    typealias CompletionHandler = (Swift.Result<Data?, NetworkError>) -> Void
    
    func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
    func requestNotReturn(request: URLRequest, completion: @escaping CompletionHandler)
    func requestNotReturnFeedCleeps(request: URLRequest, completion: @escaping (Swift.Result<Data?, NetworkErrorFeedCleeps>) -> Void, token: @escaping (String) -> Void)}

public final class RefreshTokenService: RefreshTokenManager, RefreshTokenLoader {
    
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    private var isRefreshing: Bool = false
    
    public init(sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger()) {
        self.sessionManager = sessionManager
        self.logger = logger
    }
    
    public func request(request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let sessionDataTask = sessionManager.request(makeRefreshTokenRequest()) { data, response, requestError in
            self.requestHandler(request: request, data, response, requestError, completion: completion)
            self.logger.log(request: request)
        }
        
        return sessionDataTask
    }
    
    public func requestNotReturn(request: URLRequest,
                                 completion: @escaping CompletionHandler) {

        URLSession.shared.dataTask(with: makeRefreshTokenRequest()) { data, response, requestError in
            self.requestHandler(request: request, data, response, requestError, completion: completion)
            self.logger.log(request: request)
        }.resume()
    }
    
    
    public func requestNotReturnFeedCleeps(request: URLRequest, completion: @escaping (Swift.Result<Data?, NetworkErrorFeedCleeps>) -> Void, token: @escaping (String) -> Void) {
        
        guard !isRefreshing else { return }
        isRefreshing = true
        URLSession.shared.dataTask(with: makeRefreshTokenRequest()) { data, response, requestError in
            self.logger.log(request: self.makeRefreshTokenRequest())
            if let requestError = requestError {
                var error: NetworkErrorFeedCleeps
                
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
                
            } else {
                
                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    let error = NetworkErrorFeedCleeps.error(statusCode: response.statusCode, data: data)

                    if response.statusCode == 401 {
                        completion(.failure(error))
                        return
                    }
                                        
                    NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
                    self.logger.log(error: error)
                    return
                }
                
                if let data = data {
                    do {
                        let loginData = try JSONDecoder().decode(LoginResponse.self, from: data)
                        updateLoginData(data: loginData)
                        var urlRequest = request
                        urlRequest.setValue("Bearer \(loginData.accessToken!)", forHTTPHeaderField: "Authorization")
                        
                        
                        self.logger.log(responseData: data, response: response)
                        self.updateUserData(data: data)
                        self.recallAPIFeedCleeps(request: urlRequest, completion: completion)
                    } catch {
                        let error = NetworkErrorFeedCleeps.error(statusCode: 401, data: data)
                        completion(.failure(error))
                        self.logger.log(error: error)
                    }
                } else {
                    let error = NetworkErrorFeedCleeps.error(statusCode: 401, data: data)
                    completion(.failure(error))
                    self.logger.log(error: error)
                }
                
                
            }
            self.isRefreshing = false
        }.resume()
        
        logger.log(request: request)
    }
    // MARK: - Private
    
    private func requestHandler(request: URLRequest, _ data: Data?, _ response: URLResponse?, _ error: Error?,
                                completion: @escaping (Swift.Result<Data?, NetworkError>) -> Void) {

        if let requestError = error {
            errorHandler(data, response, requestError)
            NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
        } else {
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                let error = NetworkError.error(statusCode: response.statusCode, data: data)

                if response.statusCode == 401 {
                    completion(.failure(error))
                    return
                }
                
                NotificationCenter.default.post(name: .refreshTokenFailedToComplete, object: nil)
                self.logger.log(error: error)
                return
            }
            
            if let data = data {
                do {
                    let loginData = try JSONDecoder().decode(LoginResponse.self, from: data)
                    updateLoginData(data: loginData)
                    var urlRequest = request
                    urlRequest.setValue("Bearer \(loginData.accessToken!)", forHTTPHeaderField: "Authorization")
                    
                    var dayComponent    = DateComponents()
                    dayComponent.second = loginData.expiresIn ?? 0
                    let expiredDay      = Calendar.current.date(byAdding: dayComponent, to: Date())!
                    UserDefaults.standard.set(expiredDay, forKey: "TokenExpiredDate")
                    
                    self.logger.log(responseData: data, response: response)
                    self.updateUserData(data: data)
                    self.recallAPI(request: urlRequest, completion: completion)
                } catch {
                    let error = NetworkError.error(statusCode: 401, data: data)
                    completion(.failure(error))
                    self.logger.log(error: error)
                }
            } else {
                let error = NetworkError.error(statusCode: 401, data: data)
                completion(.failure(error))
                self.logger.log(error: error)
            }
        }
    }
    
    private func recallAPI(request: URLRequest,
                           completion: @escaping CompletionHandler) {
        
        URLSession.shared.dataTask(with: request) { data, response, requestError in
            if let requestError = requestError {
                self.errorHandler(data, response, requestError) { error in
                    completion(.failure(error))
                }
                return
            }
            
            self.logger.log(responseData: data, response: response)
            completion(.success(data))
        }.resume()
    }
    
    private func recallAPIFeedCleeps(request: URLRequest,
                                     completion: @escaping (Swift.Result<Data?, NetworkErrorFeedCleeps>) -> Void) {
        
        URLSession.shared.dataTask(with: request) { data, response, requestError in
            if let requestError = requestError {
                var error: NetworkErrorFeedCleeps
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }.resume()
    }
    
    private func errorHandler(_ data: Data?, _ response: URLResponse?, _ requestError: Error,
                              completion: ((NetworkError) -> Void)? = nil) {
        var error: NetworkError
        if let response = response as? HTTPURLResponse {
            error = .error(statusCode: response.statusCode, data: data)
        } else {
            error = self.resolve(error: requestError)
        }
        
        logger.log(error: error)
        completion?(error)
    }
    
    private func makeRefreshTokenRequest() -> URLRequest {
        var urlRequest = URLRequest(url: URL(string: APIConstants.baseURL + "/auth/refresh_token")!)
        urlRequest.httpMethod = HTTPMethodType.get.rawValue
        
        let paramRequest = ["refresh_token" : getRefreshToken(), "grant_type" : "refresh_token"]
        let encodeURLRequest = urlRequest.encode(with: paramRequest)
        return encodeURLRequest
    }
    
    private func updateUserData(data: Data?) {
        do {
            guard let data = data else {
                print("User data not found!")
                removeToken()
                return
            }
            
            let result = try JSONDecoder().decode(LoginResponse.self, from: data)
            updateLoginData(data: result)
        } catch {
            print(error.localizedDescription)
            removeToken()
        }
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
    
    private func resolve(error: Error) -> NetworkErrorFeedCleeps {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}
