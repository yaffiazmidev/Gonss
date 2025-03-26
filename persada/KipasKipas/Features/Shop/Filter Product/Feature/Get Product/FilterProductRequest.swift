//
//  FilterProductRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct FilterProductRequest {
    var productCategoryId: String?
    var isVerified: Bool
    var keyword: String?
    let page, size: Int
}
