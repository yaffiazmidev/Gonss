//
//  ShopLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol ShopLoader {
    typealias Result = Swift.Result<[ShopItem], Error>
    
    func load(request: ShopRequest, completion: @escaping (Result) -> Void)
}
