//
//  ReviewLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ReviewPagedRequest: Equatable {
    let productId: String
    var page: Int
    let size: Int
    var sortBy: String
    let direction: String
    let isPublic: Bool

    init(productId: String, page: Int = 0, size: Int = 10, sortBy: String = "createAt", direction: String = "DESC", isPublic: Bool) {
        self.productId = productId
        self.page = page
        self.size = size
        self.sortBy = sortBy
        self.direction = direction
        self.isPublic = isPublic
    }
}

protocol ReviewPagedLoader {
    typealias Result = Swift.Result<Review, Error>

    func load(request: ReviewPagedRequest, completion: @escaping (Result) -> Void)
}

protocol ReviewMediaPagedLoader {
    typealias Result = Swift.Result<ReviewMediaData, Error>

    func load(request: ReviewPagedRequest, completion: @escaping (Result) -> Void)
}
