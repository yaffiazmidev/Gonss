//
//  QRProductLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct QRProductLoaderRequest: Equatable {
    let id: String
    let isPublic: Bool
    
    init(id: String, isPublic: Bool) {
        self.id = id
        self.isPublic = isPublic
    }
}

protocol QRProductLoader {
    typealias Result = Swift.Result<QRProductItem, Error>
    
    func load(request: QRProductLoaderRequest, completion: @escaping (Result) -> Void)
}
