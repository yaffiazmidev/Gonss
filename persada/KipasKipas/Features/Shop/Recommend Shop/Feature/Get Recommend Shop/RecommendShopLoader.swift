//
//  RecommendShopLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

protocol RecommendShopLoader {
    typealias Result = Swift.Result<[ShopItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
