//
//  PaymentResponse.swift
//  Persada
//
//  Created by movan on 27/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct PaymentResponse : Codable {
    
    let code : String?
    let data : PaymentToken?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
    
}

struct PaymentToken : Codable {
    
    let redirectUrl : String?
    let token : String?
    
    enum CodingKeys: String, CodingKey {
        case redirectUrl = "redirectUrl"
        case token = "token"
    }
    
}

struct ParameterOrder : Codable {
    
    let amount : Double?
    let orderDetail : OrderDetail?
    let orderShipment : OrderShipment?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case orderDetail = "orderDetail"
        case orderShipment = "orderShipment"
        case type = "type"
    }
    
}

struct ParameterDonation : Encodable {
    
    let amount : Int?
    let orderDetail : OrderDonationDetail?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case orderDetail = "orderDetail"
        case type = "type"
    }
    
}

struct OrderDonationDetail: Encodable {
    var feedId: String?
    var amount: Int?
}

struct OrderShipment : Codable {
    
    let cost : Int?
    let courier : String?
    let destinationId : String?
    let destinationSubDistrictId : String?
    let duration : String?
    let notes : String?
    let originId : String?
    let originLabel: String?
    let originPostalCode: String?
    let originSubDistrictId : String?
    let service : String?
    let destinationReceiverName: String?
    let destinationPhoneNumber: String?
    let destinationSubDistrict: String?
    let destinationCity: String?
    let destinationProvince: String?
    let alamat: String?
    let destinationDetail: String?
    let differentCost: Int?
    let bookingNumber: String?
    let actualCost: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case destinationDetail, differentCost, bookingNumber, actualCost
        case destinationReceiverName = "destinationReceiverName"
        case destinationPhoneNumber = "destinationPhoneNumber"
        case destinationSubDistrict = "destinationSubDistrict"
        case destinationCity = "destinationCity"
        case destinationProvince = "destinationProvince"
        case cost = "cost"
        case courier = "courier"
        case destinationId = "destinationId"
        case destinationSubDistrictId = "destinationSubDistrictId"
        case duration = "duration"
        case notes = "notes"
        case originId = "originId"
        case originLabel = "originLabel"
        case originPostalCode = "originPostalCode"
        case originSubDistrictId = "originSubDistrictId"
        case service = "service"
        case alamat = "originDetail"
    }

}

struct Origin : Codable {
    
    let id : String?
    let subDistrictId : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case subDistrictId = "subDistrictId"
    }

}

struct Destination : Codable {
    
    let id : String?
    let subDistrictId : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case subDistrictId = "subDistrictId"
    }

}

struct OrderDetail : Codable {
    
    let measurement : ProductMeasurement?
    let productId : String?
    let quantity : Int?
    let productName: String?
    let productPrice: Double?
    let urlProductPhoto: String?
    let createAt: Int?
    
    enum CodingKeys: String, CodingKey {
        case productName, productPrice, urlProductPhoto, createAt
        case measurement = "measurement"
        case productId = "productId"
        case quantity = "quantity"
    }

}
