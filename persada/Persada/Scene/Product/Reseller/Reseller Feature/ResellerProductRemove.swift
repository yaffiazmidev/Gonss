//
//  ResellerProductRemove.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

struct ResellerProductRemoveRequest: Equatable {
    let id: String
}

protocol ResellerProductRemove {
    typealias Result = Swift.Result<String, Error>
    
    func remove(request: ResellerProductRemoveRequest, completion: @escaping (Result) -> Void)
}
