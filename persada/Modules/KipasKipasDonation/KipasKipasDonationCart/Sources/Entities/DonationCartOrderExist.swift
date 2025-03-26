//
//  DonationCartOrderExist.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/02/24.
//

import Foundation

public struct DonationCartOrderExist: Codable {
    public let orderId: String?
    public let orderExist: Bool
    
    public init(orderId: String?, orderExist: Bool) {
        self.orderId = orderId
        self.orderExist = orderExist
    }
}
