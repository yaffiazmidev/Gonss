//
//  DetailTransactionOrderLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct DetailTransactionOrderLoaderRequest: Equatable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

protocol DetailTransactionOrderLoader{
    typealias Result = Swift.Result<DetailTransactionOrderItem, Error>
    
    func load(request: DetailTransactionOrderLoaderRequest, completion: @escaping (Result) -> Void)
}
