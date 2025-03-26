//
//  CleepsLoader.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 27/12/22.
//

import Foundation

public struct PagedCleepsLoaderRequest: Equatable {
    public var page: Int
    public var isTrending: Bool
    
    public init(page: Int, isTrending: Bool = false) {
        self.page = page
        self.isTrending = isTrending
    }
}


public protocol CleepsLoader {
    typealias Result = Swift.Result<FeedArray, Error>
    
    func load(request: PagedCleepsLoaderRequest, completion: @escaping (Result) -> Void)
}
