//
//  ResellerProductLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 09/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ResellerProductLoader {
    typealias Result = Swift.Result<ResellerProductItem, Error>
    
    func load(request: ResellerProductRequest, completion: @escaping (Result) -> Void)
}
