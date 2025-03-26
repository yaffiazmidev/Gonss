//
//  AuthOTPLoader.swift
//  KipasKipas
//
//  Created by DENAZMI on 06/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol AuthOTPLoader {
    typealias Result = Swift.Result<AuthOTPItem, Error>
    
    func load(request: AuthOTPRequest, completion: @escaping (Result) -> Void)
}
