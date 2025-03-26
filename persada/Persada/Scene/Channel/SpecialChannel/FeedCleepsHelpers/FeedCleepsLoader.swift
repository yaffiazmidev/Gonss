//
//  FeedCleepsLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 10/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct PagedFeedCleepsLoaderRequest: Equatable {
    public var page: Int
    
    init(page: Int) {
        self.page = page
    }
}

protocol FeedCleepsLoader {
    typealias Result = Swift.Result<FeedArray, Error>
    
    func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (Result) -> Void)
}

