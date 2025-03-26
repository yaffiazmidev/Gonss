//
//  ProductTypw.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum ProductType: String {
    case all = ""
    case original = "ORIGINAL"
    case reseller = "RESELLER"
    
    var name: String {
        switch self {
        case .all:
            return "Semua"
        case .original:
            return "Produk Saya"
        case .reseller:
            return "Produk Resell"
        }
    }
}
