//
//  CategoryShopLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol CategoryShopLoader {
    typealias Result = Swift.Result<[CategoryShopItem], Error>
    
    func load(request: CategoryShopRequest, completion: @escaping (Result) -> Void)
}
