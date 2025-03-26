//
//  DetailTransactionProductLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct DetailTransactionProductLoaderRequest: Equatable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

protocol DetailTransactionProductLoader{
    typealias Result = Swift.Result<DetailTransactionProductItem, Error>
    
    func load(request: DetailTransactionProductLoaderRequest, completion: @escaping (Result) -> Void)
}
