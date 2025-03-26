//
//  RemoteFeedDonationModuleLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 23/02/23.
//

import Foundation
import KipasKipasNetworking
import KipasKipasShared

public class RemoteFeedDonationModuleLoader: FeedCleepsLoader {
    
    private let baseURL: String
    private var token: String
    private let isTokenExpired: Bool
    private let refreshTokenService: RefreshTokenLoader
    private let client = TimeOutURLSession()
    private let logger: INetworkErrorLogger
    
    public init(baseURL: String,
                token: String,
                isTokenExpired: Bool,
                refreshTokenService: RefreshTokenLoader,
                logger: INetworkErrorLogger = NetworkErrorLogger())
    {
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.baseURL = baseURL
        self.token =  HelperSingleton.shared.token
        self.isTokenExpired = isTokenExpired
        self.refreshTokenService = refreshTokenService
        self.logger = logger
    }

    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        
        var vodParam = ""
        var provinceIdParam = ""
        var coordinateParam = ""
        
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }
        
        if let provinceId = request.provinceId {
            provinceIdParam = "&provinceId=\(provinceId)"
        }
        
        if let long = request.longitude, let lat = request.latitude {
            coordinateParam = "&longitude=\(long)&latitude=\(lat)"
        }
        
        let isPublic = HelperSingleton.shared.token.isEmpty ? "/public" : ""
        let path = "\(isPublic)/feeds/post/donation"
        
        let queryParam = "?size=10&page=\(request.page)&sort=createAt,desc&categoryId=\(request.categoryId)\(vodParam)\(provinceIdParam)\(coordinateParam)"
        let urlString = "\(baseURL)\(path)\(queryParam)"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        
        urlRequest.httpMethod = "GET"
        
        if !token.isEmpty {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        logger.log(request: urlRequest)
        let startTime = CFAbsoluteTimeGetCurrent()
        
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok Donation \(timeElapsed) s")
            
            self.logger.log(responseData: data, response: response)
            
            guard let response = response as? HTTPURLResponse else {
                if(error != nil){
                    KKLogger.instance.send(title: "RemoteFeedDonationModuleLoader-1 Error:", message: error?.localizedDescription ?? "")
                }

                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, completion: completion)
                return
            }
            
            self.logger.log(responseData: data, response: response)
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(FeedArray.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch let error {
                    self.logger.log(error: error)
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                self.logger.log(error: error)
                completion(.failure(error))
            }
        }
    }
    
    private func refreshTokenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.logger.log(error: error)
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
                logger.log(error: error)
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            let result: FeedArray = try decoder.decode(FeedArray.self, from: data)
            completion(.success(result))
        } catch let error {
            logger.log(error: error)
            completion(.failure(error))
        }
    }

}

extension RemoteFeedDonationModuleLoader {
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
            
            self.logger.log(responseData: data, response: response)
            
            guard let response = response as? HTTPURLResponse else {
                if(error != nil){
                    KKLogger.instance.send(title: "RemoteFeedDonationModuleLoader-2 Error:", message: error?.localizedDescription ?? "")
                }

                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
                self.refreshTokenSeenHandler(request: urlRequest, completion: completion)
                return
            }
            
            self.logger.log(responseData: data, response: response)
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(SeenResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(jsonData))
                    }
                } catch let error {
                    self.logger.log(error: error)
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                self.logger.log(error: error)
                completion(.failure(error))
            }
        }
    }
    
    private func refreshTokenSeenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.SeenResult) -> Void) {
        refreshTokenService.requestNotReturnFeedCleeps(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.logger.log(error: error)
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
                logger.log(error: error)
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            let result: SeenResponse = try decoder.decode(SeenResponse.self, from: data)
            completion(.success(result))
        } catch let error {
            logger.log(error: error)
            completion(.failure(error))
        }
    }

}
