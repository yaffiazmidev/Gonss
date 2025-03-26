//
//  ProfileNetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 04/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

final class ProfileNetworkModel: NetworkModel {
    typealias Result = Swift.Result<ProfileResult, Error>
    
    func profileUsername(baseURL: String, token: String, username: String, completion: @escaping (ProfileNetworkModel.Result) -> Void) {
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)/profile/username?value=\(username)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(ProfileResult.self, from: data)
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
        }.resume()
    }
}

typealias Parameters = [String: Any]

extension URLRequest {
    func encode(with parameters: Parameters?) -> URLRequest {
        guard let parameters = parameters else {
            return self
        }
        
        var encodedURLRequest = self
        
        if let url = self.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            var newUrlComponents = urlComponents
            let queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: String(describing: value))
            }
            
            newUrlComponents.queryItems = queryItems
            encodedURLRequest.url = newUrlComponents.url
            return encodedURLRequest
        } else {
            return self
        }
    }
}
