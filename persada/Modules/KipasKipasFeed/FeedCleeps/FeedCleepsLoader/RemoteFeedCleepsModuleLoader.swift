//
//  RemoteCleepsLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 10/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import KipasKipasNetworking
import KipasKipasShared

public enum NetworkErrorFeedCleeps: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

public protocol RefreshTokenLoader {
    func requestNotReturnFeedCleeps(request: URLRequest, completion: @escaping (Swift.Result<Data?, NetworkErrorFeedCleeps>) -> Void, token: @escaping (String) -> Void)
}

public class RemoteFeedCleepsModuleLoader: FeedCleepsLoader {
    
    private let usecase: FeedUseCase!
    private let disposeBag = DisposeBag()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let baseURL: String
    private var token: String
    private let isTokenExpired: Bool
    private let cleepsCountry: CleepsCountry
    private let refreshTokenService: RefreshTokenLoader
    private let client = TimeOutURLSession()
    private let httpClient: HTTPClient

    public init(cleepsCountry: CleepsCountry, baseURL: String, token: String, isTokenExpired: Bool, refreshTokenService: RefreshTokenLoader, httpClient: HTTPClient) {
        //print("**** RemoteFeedCleepsModuleLoader init")
        HelperSingleton.shared.baseURL = baseURL
        HelperSingleton.shared.token = token
        self.cleepsCountry = cleepsCountry
        self.baseURL = baseURL
        self.token =  HelperSingleton.shared.token
        self.usecase = Injection.init().provideFeedUseCase(endpoint: baseURL)
        self.isTokenExpired = isTokenExpired
        self.refreshTokenService = refreshTokenService
        self.httpClient = httpClient
    }

    public func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        var isPublic = HelperSingleton.shared.token.isEmpty ? "/public" : ""
        
        var vodParam = ""
        if let isVodAvailable = request.isVodAvailable {
            vodParam = "&isVodAvailable=\(isVodAvailable)"
        }

        var urlRequest = URLRequest(url: URL(string: "\(baseURL)\(isPublic)/feeds/channels?code=\(cleepsCountry.rawValue)&page=\(request.page)&size=\(request.size)\(vodParam)")!)
                
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let startTime = CFAbsoluteTimeGetCurrent()
        log(request: urlRequest)
        
        token = HelperSingleton.shared.token
//        if token == "" {
//            completion(.failure(NSError(domain: "Error Token", code: 401)))
//            return
//        }
        
        client.load(with: urlRequest) { [weak self, urlRequest] data, response, error in
            guard let self = self else { return }
            
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("----DEBUG GetNEtwok Cleeps \(self.cleepsCountry) : \(timeElapsed) s")



            guard let response = response as? HTTPURLResponse else {
                if(error != nil){
                    KKLogger.instance.send(title: "PagedFeedCleepsLoaderRequest Error:", message: error?.localizedDescription ?? "")
                }

                completion(.failure(NSError(domain: "Response not found..", code: 404)))
                return
            }
            
            if response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, completion: completion)
                return
            }
            
            self.log(responseData: data, response: response)
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    var jsonData = try decoder.decode(FeedArray.self, from: data)
                    for i in 0..<(jsonData.data?.content?.count ?? 0){
                        jsonData.data?.content?[i].isTrending = request.isTrending
                    }
                    let data = jsonData
                    DispatchQueue.main.async {
                        completion(.success(data))
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
    
    public func log(responseData data: Data?, response: URLResponse?) {
        if let response = response as? HTTPURLResponse {
            print("STATUS CODE : \(response.statusCode)")
            print("=================================================")
        }
        
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            //printIfDebug("RESPONSE DATA: \(String(describing: dataDict))")
            print("=================================================")
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
//        #if DEBUG
            print(item)
//        #elseif STAGING
//            print(item)
//        #endif
    }

}

extension RemoteFeedCleepsModuleLoader {
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
