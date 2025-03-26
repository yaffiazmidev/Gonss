//
//  SearchProductLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol FilterProductLoader {
    typealias Result = Swift.Result<[ShopItem], Error>
    
    func load(request: FilterProductRequest, completion: @escaping (Result) -> Void)
}
