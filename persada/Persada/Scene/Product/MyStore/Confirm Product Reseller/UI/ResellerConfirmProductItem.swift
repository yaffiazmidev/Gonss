//
//  ResellerConfirmProductItem.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ResellerConfirmProductItem {
    var id: String?
    var accountId: String?
    var productName: String?
    var sellerName: String?
    var price: Double?
    var commission: Double?
    var modal: Double?
    var isDelete: Bool?
    var imageURL: String?
    var name: String?
    var username: String?
    var photo: String?
    var isVerified: Bool?
    var isAlreadyReseller: Bool?
    
    init(id: String? = nil, accountId: String? = nil, productName: String? = nil, sellerName: String? = nil, price: Double? = nil, commission: Double? = nil, modal: Double? = nil, isDelete: Bool? = nil, imageURL: String? = nil, name: String? = nil, username: String? = nil, photo: String? = nil, isVerified: Bool? = nil, isAlreadyReseller: Bool? = nil) {
        self.id = id
        self.accountId = accountId
        self.productName = productName
        self.sellerName = sellerName
        self.price = price
        self.commission = commission
        self.modal = modal
        self.isDelete = isDelete
        self.imageURL = imageURL
        self.name = name
        self.username = username
        self.photo = photo
        self.isVerified = isVerified
        self.isAlreadyReseller = isAlreadyReseller
    }
}
