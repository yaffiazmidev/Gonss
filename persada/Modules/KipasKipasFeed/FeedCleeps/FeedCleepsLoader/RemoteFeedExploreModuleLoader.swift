//
//  RemoteFeedExploreModuleLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 29/09/22.
//

import Foundation
import KipasKipasNetworking

public class RemoteFeedExploreModuleLoader: FeedCleepsLoader {
    
    private let baseURL: String
    private var token: String
    private let isLogin: Bool
    private let isTokenExpired: Bool
    private let refreshTokenService: RefreshTokenLoader
    private let client = TimeOutURLSession()
    private let httpClient: HTTPClient


    public init(baseURL: String, token: String, isLogin: Bool, isTokenExpired: Bool, refreshTokenService: RefreshTokenLoader, httpClient: HTTPClient) {
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.baseURL = baseURL
        self.token = token
        self.isLogin = isLogin
        self.isTokenExpired = isTokenExpired
        self.refreshTokenService = refreshTokenService
        self.httpClient = httpClient
    }

    
    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        let isPublic = !isLogin ? "public" : ""
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        let path = "\(isPublic)/channels/general/posts"
        let url = URL(string: "\(baseURL)/\(path)?size=\(request.size)&page=\(request.page)&sort=createAt,desc\(vodParam)")!
        var urlRequest = URLRequest(url: url)
          
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        log(request: urlRequest)
        
        token = HelperSingleton.shared.token
        if token == "" {
            completion(.failure(NSError(domain: "Error Token", code: 401)))
            return
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok EXPLORE Feed : \(timeElapsed) s")
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, completion: completion)
                return
            }
            
            self.decode(data: data, completion: completion)
        }
    }
    
    private func refreshTokenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.decode(data: data, completion: completion)
            }
        } token: { [weak self] token in
            self?.token = token
        }
    }
    
    private func decode(data: Data?, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        do {
            guard let data = data else {
                let error = NSError(domain: "Data not found!", code: 404)
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            let result: FeedArray = try decoder.decode(FeedArray.self, from: data)
            completion(.success(result))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func log(request: URLRequest) {
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
    
    private func printIfDebug(_ item: String) {
        #if DEBUG
            print(item)
        #elseif STAGING
            print(item)
        #endif
    }
}

extension RemoteFeedExploreModuleLoader {
    public func seen(request: SeenFeedCleepsRequest, completion: @escaping (SeenResult) -> Void) {
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)/feeds/\(request.feedID)/seen")!)
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        token = HelperSingleton.shared.token
        if token == "" {
            completion(.failure(NSError(domain: "Error Token", code: 401)))
            return
        }
        
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                self.refreshTokenSeenHandler(request: urlRequest, completion: completion)
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(SeenResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(jsonData))
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    private func refreshTokenSeenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.SeenResult) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.decode(data: data, completion: completion)
            }
        } token: { [weak self] token in
            self?.token = token
            HelperSingleton.shared.token = token
        }

    }
    
    private func decode(data: Data?, completion: @escaping (FeedCleepsLoader.SeenResult) -> Void) {
        do {
            guard let data = data else {
                let error = NSError(domain: "Data not found!", code: 404)
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            let result: SeenResponse = try decoder.decode(SeenResponse.self, from: data)
            completion(.success(result))
        } catch let error {
            completion(.failure(error))
        }
    }

}
