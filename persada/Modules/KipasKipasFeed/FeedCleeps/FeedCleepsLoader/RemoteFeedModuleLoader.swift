//
//  RemoteFeedLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 10/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import KipasKipasNetworking

public class RemoteFeedModuleLoader: FeedCleepsLoader {
    
    private let usecase: FeedUseCase!
    private let disposeBag = DisposeBag()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let baseURL: String
    private var token: String
    private let client = TimeOutURLSession()
    private let httpClient: HTTPClient
    private let refreshTokenService: RefreshTokenLoader


    public init(baseURL: String, token: String, httpClient: HTTPClient, refreshTokenService: RefreshTokenLoader) {
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.baseURL = baseURL
        self.token = token
        self.usecase = Injection.init().provideFeedUseCase(endpoint: baseURL)
        self.httpClient = httpClient
        self.refreshTokenService =  refreshTokenService
    }

    
    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        let isPublic = HelperSingleton.shared.token.isEmpty ? "/public" : ""
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)\(isPublic)/feeds/post/home?size=\(request.size)&page=\(request.page)&sort=createAt,desc\(vodParam)")!)
          
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        client.load(with: urlRequest) { [weak self] data, response, error in
            guard self != nil else { return }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok Feed : \(timeElapsed) s")
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(FeedArray.self, from: data)
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
}

extension RemoteFeedModuleLoader {
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
