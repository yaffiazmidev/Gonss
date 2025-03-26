//
//  ProductDetailLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ProductDetailLoader{
    typealias Result = Swift.Result<ProductDetailItem, Error>
    
    func load(request: ProductDetailRequest, completion: @escaping (Result) -> Void)
}
