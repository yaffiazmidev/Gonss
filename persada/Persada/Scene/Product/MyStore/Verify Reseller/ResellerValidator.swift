//
//  ResellerValidator.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ResellerValidator {
    typealias Result = Swift.Result<ResellerValidatorResponseItem, Error>
    
    func verify(completion: @escaping (Result) -> Void)
}

