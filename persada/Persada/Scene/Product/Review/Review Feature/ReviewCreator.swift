//
//  ReviewCreator.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 19/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct ReviewCreateRequest: Equatable{
    let orderId: String
    let body: ReviewCreateBodyRequest
    
    init(orderId: String, body: ReviewCreateBodyRequest) {
        self.orderId = orderId
        self.body = body
    }
}

struct ReviewCreateBodyRequest: Equatable, Encodable{
    let medias: [ReviewMedia]
    let isAnonymous: Bool
    let review: String
    let rating: Double
    
    init(medias: [ReviewMedia], isAnonymous: Bool, review: String, rating: Double) {
        self.medias = medias
        self.isAnonymous = isAnonymous
        self.review = review
        self.rating = rating
    }
}

protocol ReviewCreator {
    typealias Result = Swift.Result<Data?, Error>
    
    func create(request: ReviewCreateRequest, completion: @escaping (Result) -> Void)
}
