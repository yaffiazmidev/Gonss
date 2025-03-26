//
//  ResellerProductConfirm.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation


struct ResellerProductConfirmRequest: Encodable {
    let id: String
}

protocol ResellerProductConfirm {
    typealias Result = Swift.Result<ResellerProductDefaultItem, Error>
    
    func confirm(request: ResellerProductConfirmRequest, completion: @escaping (Result) -> Void)
}
