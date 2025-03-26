//
//  UserSellerLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct UserSellerRequest {
    let id: String
}

protocol UserSellerLoader {
    typealias Result = Swift.Result<UserSellerItem, Error>
    
    func load(request: UserSellerRequest, completion: @escaping (Result) -> Void)
}


