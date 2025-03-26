//
//  FollowingSuggestionLoader.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation

public struct PagedFollowingSuggestionLoaderRequest: Equatable {
    public var page: Int
    
    public init(page: Int) {
        self.page = page
    }
}

public protocol FollowingSuggestionLoader {
    typealias Result = Swift.Result<FollowingSuggestionItem, Error>
    
    func load(request: PagedFollowingSuggestionLoaderRequest, completion: @escaping (Result) -> Void)
}
