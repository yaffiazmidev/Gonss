//
//  File.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

// MARK: - CheckoutOrderModel
struct CheckoutOrderRequest: Codable {
    let amount: Int
    let type: String
    let orderDetail: OrderDetailCheckout
    let orderShipment: OrderShipmentCheckout
}

// MARK: - OrderDetail
struct OrderDetailCheckout: Codable {
    let productID: String
    let quantity: Int
    let variant: String
    let measurement: ProductMeasurement

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case quantity, variant, measurement
    }
}

// MARK: - OrderShipment
struct OrderShipmentCheckout: Codable {
    let destinationID, destinationSubDistrictID : String
    let notes: String
    let cost: Int
    let service, courier, duration: String

    enum CodingKeys: String, CodingKey {
        case destinationID = "destinationId"
        case destinationSubDistrictID = "destinationSubDistrictId"
        case notes, cost, service, courier, duration
    }
}
