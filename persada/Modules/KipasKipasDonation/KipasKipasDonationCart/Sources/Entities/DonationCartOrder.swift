//
//  DonationCartOrder.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/02/24.
//

import Foundation

public struct DonationCartOrder: Codable {
    public let redirectUrl: String
    public let token: String
    public let orderId: String
}
