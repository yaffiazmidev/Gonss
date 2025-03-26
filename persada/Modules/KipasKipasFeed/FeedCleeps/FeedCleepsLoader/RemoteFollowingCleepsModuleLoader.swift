//
//  RemoteFollowingCleepsModuleLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 30/11/22.
//

import Foundation
import KipasKipasShared
import KipasKipasNetworking

public class RemoteFollowingCleepsModuleLoader: FeedCleepsLoader {
    
    private let baseURL: String
    private var token: String
    private let isTokenExpired: Bool
    private let refreshTokenService: RefreshTokenLoader
    private let client = TimeOutURLSession()
    private let logger: INetworkErrorLogger
    private let httpClient: HTTPClient

    public init(
        baseURL: String,
        token: String,
        isTokenExpired: Bool,
        refreshTokenService: RefreshTokenLoader,
        logger: INetworkErrorLogger = NetworkErrorLogger(),
        httpClient: HTTPClient)
    {
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.baseURL = baseURL
        self.token = token
        self.isTokenExpired = isTokenExpired
        self.refreshTokenService = refreshTokenService
        self.logger = logger
        self.httpClient = httpClient
    }

    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)/feeds/following?size=\(request.size)&page=\(request.page)\(vodParam)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        token = HelperSingleton.shared.token
        if token == "" {
            completion(.failure(NSError(domain: "Error Token", code: 401)))
            return
        }
        
        logger.log(request: urlRequest)
        client.load(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok Following Cleeps : \(timeElapsed) s")
            
            if let error = error {
                self.logger.log(error: error)
                completion(.failure(error))
            }
            
            self.decode(data, response, completion: completion)
        }
    }
    
    private func refreshTokenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.decode(data, completion: completion)
            }
        } token: { [weak self] token in
            self?.token = token
            HelperSingleton.shared.token = token
        }
    }
    
    private func decode(_ data: Data?, _ response: URLResponse? = nil, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        do {
            
            logger.log(responseData: data, response: response)
            
            guard let data = data else {
                let error = NSError(domain: "Data not found..", code: 404)
                logger.log(error: error)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                let error = NSError(domain: String(data: data, encoding: .utf8) ?? "Something wrong..", code: response.statusCode)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            let result: FeedArray = try JSONDecoder().decode(FeedArray.self, from: data)
            DispatchQueue.main.async { completion(.success(result)) }
        } catch {
            logger.log(error: error)
            DispatchQueue.main.async { completion(.failure(error)) }
        }
    }
}

extension RemoteFollowingCleepsModuleLoader {
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
            
            guard let response = response as? HTTPURLResponse else {
                
                if(error != nil){
                    KKLogger.instance.send(title: "RemoteFollowingCleepsModuleLoader Error:", message: error?.localizedDescription ?? "")
                }

                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
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
