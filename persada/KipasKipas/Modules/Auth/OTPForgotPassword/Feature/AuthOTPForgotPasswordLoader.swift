//
//  AuthOTPForgotPasswordLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol AuthOTPForgotPasswordLoader {
    typealias Result = Swift.Result<AuthOTPForgotPasswordItem, Error>
    
    func load(request: AuthOTPForgotPasswordRequest, completion: @escaping (Result) -> Void)
}
