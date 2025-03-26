//
//  RemoteFeedLoader.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 24/09/23.
//

import Foundation

struct PagedFeedLoaderRequest {
    let page: Int
}

protocol FeedLoader {
    func load(request: PagedFeedLoaderRequest, completion: @escaping (Swift.Result<RemoteFeed, Error>) -> Void)
}

class RemoteFeedLoader: FeedLoader {
    
    init() {}
    
    func load(request: PagedFeedLoaderRequest, completion: @escaping (Swift.Result<RemoteFeed, Error>) -> Void) {
        
        if let jsonData = loadJSONData(from: "Feeds-\(request.page)") {
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(RemoteFeed.self, from: jsonData)
                completion(.success(response))
            } catch let error {
                completion(.failure(error))
            }
        } else {
            completion(.failure(NSError(domain: "Failed to load JSON data", code: 404)))
            print("Failed to load JSON data")
        }
    }
    
    func loadJSONData(from fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}
