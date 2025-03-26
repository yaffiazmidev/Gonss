//
//  CourierLoader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 18/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

protocol CourierLoader {
    typealias Result = Swift.Result<[CourierItem], Error>
    
    func load(request: CourierRequest, completion: @escaping (Result) -> Void)
}

