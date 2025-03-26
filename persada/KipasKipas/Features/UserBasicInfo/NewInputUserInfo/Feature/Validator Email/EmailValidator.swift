//
//  InputUserWithEmailChecker.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol EmailValidator {
    typealias Result = Swift.Result<EmailValidatorResponseItem, Error>
    
    func check(request: EmailValidatorRequest, completion: @escaping (Result) -> Void)
}
