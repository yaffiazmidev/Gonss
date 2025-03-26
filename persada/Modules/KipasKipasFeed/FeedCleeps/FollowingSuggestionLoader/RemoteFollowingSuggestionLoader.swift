//
//  RemoteFollowingSuggestionLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation
import KipasKipasShared
import KipasKipasNetworking

public class RemoteFollowingSuggestionLoader: FollowingSuggestionLoader {
    
    private let url: URL
    private let logger: INetworkErrorLogger
    private let client: HTTPClient

    public init(
        url: URL,
        logger: INetworkErrorLogger = NetworkErrorLogger(),
        client: HTTPClient)
    {
        self.url = url
        self.logger = logger
        self.client = client
    }

    public func load(request: PagedFollowingSuggestionLoaderRequest, completion: @escaping (FollowingSuggestionLoader.Result) -> Void) {
        
        let request = FollowingSuggestionEndpoint.get(request: request).url(baseURL: url)
        logger.log(request: request)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                self.logger.log(responseData: data, response: response)
                completion(RemoteFollowingSuggestionLoader.map(data, from: response))
            } catch {
                self.logger.log(error: error)
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> FollowingSuggestionLoader.Result {
        do {
            let items = try FollowingSuggestionContentMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}


public class HardcodeRemoteFollowingSuggestionLoader: FollowingSuggestionLoader {
    
    private let url: URL
    private let logger: INetworkErrorLogger
    private let httpClient: HTTPClient
    private let refreshTokenService: RefreshTokenLoader
    private var token: String
    private let client = TimeOutURLSession()

    public init(
        url: URL,
        logger: INetworkErrorLogger = NetworkErrorLogger(),
        httpClient: HTTPClient,
        token: String,
        refreshTokenService: RefreshTokenLoader)
    {
        self.url = url
        self.logger = logger
        self.httpClient = httpClient
        self.token = token
        self.refreshTokenService = refreshTokenService
    }

    public func load(request: PagedFollowingSuggestionLoaderRequest, completion: @escaping (FollowingSuggestionLoader.Result) -> Void) {
        
        var urlRequest = FollowingSuggestionEndpoint.get(request: request).url(baseURL: url)
        
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let startTime = CFAbsoluteTimeGetCurrent()

        logger.log(request: urlRequest)

        token = HelperSingleton.shared.token
        if token == "" {
            completion(.failure(NSError(domain: "Error Token", code: 401)))
            return
        }
        
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok FollowingSuggestion : \(timeElapsed) s")
            
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, from: response, completion: completion)
                return
            }
            if let data = data, let response = response as? HTTPURLResponse {
                self.logger.log(responseData: data, response: response)
                completion(HardcodeRemoteFollowingSuggestionLoader.map(data, from: response))
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> FollowingSuggestionLoader.Result {
        do {
            let items = try FollowingSuggestionContentMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
    
    private func refreshTokenHandler(request: URLRequest, from response: HTTPURLResponse, completion: @escaping (FollowingSuggestionLoader.Result) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if let data = data {
                    self.logger.log(responseData: data, response: response)
                    completion(HardcodeRemoteFollowingSuggestionLoader.map(data, from: response))
                }
            }
        } token: { [weak self] token in
            self?.token = token
            HelperSingleton.shared.token = token
        }
    }
}
