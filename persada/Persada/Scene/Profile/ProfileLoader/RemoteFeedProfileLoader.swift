//
//  RemoteFeedProfileLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/07/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct PagedFeedProfileLoaderRequest: Equatable {
    public var userId: String
    public var page: Int
    
    init(userId: String, page: Int) {
        self.page = page
        self.userId = userId
    }
}

protocol FeedProfileLoader {
    typealias Result = Swift.Result<FeedArray, Error>
    
    func load(request: PagedFeedProfileLoaderRequest, completion: @escaping (Result) -> Void)
}


class RemoteFeedProfileLoader: FeedProfileLoader {
    
    let refreshTokenService: RefreshTokenService
    
    init(refreshToken: RefreshTokenService = RefreshTokenService()) {
        self.refreshTokenService = refreshToken
    }
    
    func load(request: PagedFeedProfileLoaderRequest, completion: @escaping (FeedProfileLoader.Result) -> Void) {
        var urlRequest = URLRequest(url: URL(string: "\(APIConstants.baseURL)/profile/post/\(request.userId)?page=\(request.page)&size=10")!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("azmiiiiiiii", urlRequest.url?.absoluteURL)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                self.refreshTokenHandler(request: urlRequest, completion: completion)
                return
            }
            
            self.log(request: urlRequest)
            if let error = error {
                completion(.failure(error))
                return
            }
            
            self.decode(data: data, completion: completion)
        }.resume()
    }
    
    private func refreshTokenHandler(request: URLRequest, completion: @escaping (FeedCleepsLoader.Result) -> Void) {
        refreshTokenService.requestNotReturn(request: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.decode(data: data, completion: completion)
            }
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
            print("-- RESULT", result.data?.content?.first?.comments)
            completion(.success(result))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func log(request: URLRequest) {
        print("\n======================================================================")
        print("REQUEST: \(request.url!)")
        print("HEADERS: \(request.allHTTPHeaderFields!)")
        print("METHOD: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            print("BODY    : \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("BODY    : \(String(describing: resultString))")
        }
    }
}
