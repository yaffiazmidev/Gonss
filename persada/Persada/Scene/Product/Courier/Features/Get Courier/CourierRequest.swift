//
//  CourierRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public struct CourierRequest: Encodable {
    let addressId: String
    let productId: String
    let quantity: Int
}
