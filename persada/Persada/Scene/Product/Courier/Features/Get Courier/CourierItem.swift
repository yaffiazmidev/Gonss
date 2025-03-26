//
//  CourierItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct CourierItem {
    let name : String?
    let prices : [CourierItemPrice]?
}

struct CourierItemPrice {
    let duration : String?
    let price : Int?
    let service : String?
}
