//
//  CreateUser.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol CreateUser {
    typealias Result = Swift.Result<UserItem, Error>
    
    func create(request: CreateUserRequest, completion: @escaping (Result) -> Void)
}
