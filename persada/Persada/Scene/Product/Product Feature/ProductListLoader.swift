//
//  ProductLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared
import FeedCleeps

struct ProductListLoaderRequest: Equatable {
    let accountId: String
    let size: Int
    let page: Int
    let sortBy: String
    let direction: String
    let type: String
    
    init(accountId: String, size: Int = 10, page: Int, sortBy: String = "createAt", direction: String = "DESC", type: String) {
        self.accountId = accountId
        self.size = size
        self.page = page
        self.sortBy = sortBy
        self.direction = direction
        self.type = type
    }
}

protocol ProductListLoader{
    typealias Result = Swift.Result<ProductArrayItem, Error>
    
    func load(request: ProductListLoaderRequest, completion: @escaping (Result) -> Void)
}

extension MainQueueDispatchDecorator: ProductListLoader where T == ProductListLoader {
    func load(request: ProductListLoaderRequest, completion: @escaping (Swift.Result<ProductArrayItem, Error>) -> Void) {
        decoratee.load(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

