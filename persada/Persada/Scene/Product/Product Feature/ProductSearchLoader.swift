//
//  ProductLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ProductSearchLoaderRequest: Equatable {
    let accountId: String
    let size: Int
    let page: Int
    let sortBy: String
    let direction: String
    let type: String
    let keyword: String
    
    init(accountId: String, size: Int = 10, page: Int, sortBy: String = "createAt", direction: String = "DESC", type: String, keyword: String) {
        self.accountId = accountId
        self.size = size
        self.page = page
        self.sortBy = sortBy
        self.direction = direction
        self.type = type
        self.keyword = keyword
    }
}

protocol ProductSearchLoader{
    typealias Result = Swift.Result<ProductArrayItem, Error>
    
    func load(request: ProductSearchLoaderRequest, completion: @escaping (Result) -> Void)
}
