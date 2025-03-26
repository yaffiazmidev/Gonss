//
//  AuthOTPBankAccountLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol AuthOTPBankAccountLoader {
    typealias Result = Swift.Result<AuthOTPBankAccountItem, Error>
    
    func load(request: AuthOTPBankAccountRequest, completion: @escaping (Result) -> Void)
}
