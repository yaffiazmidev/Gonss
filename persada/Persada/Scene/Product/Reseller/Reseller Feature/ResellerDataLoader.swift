//
//  ResellerDataLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ResellerDataLoaderRequest: Equatable {
    let keyword: String
    let size: Int
    let page: Int
    let sortBy: String
    let direction: String
    
    init(keyword: String, size: Int = 10, page: Int, sortBy: String = "createAt", direction: String = "DESC") {
        self.keyword = keyword
        self.size = size
        self.page = page
        self.sortBy = sortBy
        self.direction = direction
    }
}

protocol ResellerDataLoader{
    typealias Result = Swift.Result<ProductArrayItem, Error>
    
    func load(request: ResellerDataLoaderRequest, completion: @escaping (Result) -> Void)
}
