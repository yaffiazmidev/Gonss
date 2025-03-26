//
//  UsernameValidator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UsernameValidator {
    typealias Result = Swift.Result<UsernameValidatorResponseItem, Error>
    
    func check(request: UsernameValidatorRequest, completion: @escaping (Result) -> Void)
}
