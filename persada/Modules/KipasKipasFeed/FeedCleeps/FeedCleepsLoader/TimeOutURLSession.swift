//
//  TimeOutURLSession.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 10/11/22.
//

import Foundation

class TimeOutURLSession {
    
    func load(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        URLSession(configuration: configuration).dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            completionHandler(data, response, error)
        }.resume()
    }
}
