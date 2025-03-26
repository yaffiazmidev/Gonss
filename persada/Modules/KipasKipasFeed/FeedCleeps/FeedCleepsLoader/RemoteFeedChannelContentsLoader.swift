//
//  RemoteFeedChannelContentsLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 26/10/22.
//

import Foundation
import RxSwift
import RxCocoa
import KipasKipasNetworking
import KipasKipasShared

public class RemoteFeedChannelContentsLoader: FeedCleepsLoader {
    
    private let usecase: FeedUseCase!
    private let disposeBag = DisposeBag()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let baseURL: String
    private var token: String
    private let channelId: String
    private let client = TimeOutURLSession()
    private let httpClient: HTTPClient
    private let refreshTokenService: RefreshTokenLoader


    public init(baseURL: String, token: String, channelId: String, httpClient: HTTPClient, refreshTokenService: RefreshTokenLoader) {
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.baseURL = baseURL
        self.token = token
        self.usecase = Injection.init().provideFeedUseCase(endpoint: baseURL)
        self.channelId = channelId
        self.httpClient = httpClient
        self.refreshTokenService = refreshTokenService
    }

    
    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        let isPublic = HelperSingleton.shared.token.isEmpty ? "/public" : ""
        
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)\(isPublic)/feeds/channel/\(channelId)?size=\(request.size)&page=\(request.page)\(vodParam)")!)
          
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


extension RemoteFeedChannelContentsLoader {
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
                    KKLogger.instance.send(title: "RemoteFeedChannelContentsLoader Error:", message: error?.localizedDescription ?? "")
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

