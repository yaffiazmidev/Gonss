//
//  RemoteHashtagsLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 31/08/22.
//

import Foundation
import KipasKipasNetworking
import KipasKipasShared

public class RemoteHashtagLoader: FeedCleepsLoader {
    
    private let hashtag: String
    private let baseURL: String
    private var token: String
    private let isTokenExpired: Bool
    private let refreshTokenService: RefreshTokenLoader
    private let client = TimeOutURLSession()
    private let httpClient: HTTPClient
    
    
    public init(hashtag: String, baseURL: String, token: String, isTokenExpired: Bool, refreshTokenService: RefreshTokenLoader, httpClient: HTTPClient) {
        print("**** RemoteHashtagLoader init")
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.hashtag = hashtag
        self.baseURL = baseURL
        self.token = token
        self.isTokenExpired = isTokenExpired
        self.refreshTokenService = refreshTokenService
        self.httpClient = httpClient
    }
    
    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        print("**** RemoteHashtagLoader load")
        
        let url = URL(string: "\(baseURL)/feeds/search/hashtag?size=\(request.size)&page=\(request.page)&sort=id&value=\(hashtag)\(vodParam)")!
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        token = HelperSingleton.shared.token
        if token == "" {
            completion(.failure(NSError(domain: "Error Token", code: 401)))
            return
        }
        
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok Hashtag : \(timeElapsed) s")
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data not found..", code: 404)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                if(error != nil){
                    KKLogger.instance.send(title: "RemoteHashtagLoader Error:", message: error?.localizedDescription ?? "")
                }

                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, completion: completion)
                return
            }
            
            if response.statusCode != 200 {
                completion(.failure(NSError(domain: String(data: data, encoding: .utf8) ?? "", code: response.statusCode)))
                return
            }
            
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
    }
    
    private func refreshTokenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { result in
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
}

extension RemoteHashtagLoader {
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
