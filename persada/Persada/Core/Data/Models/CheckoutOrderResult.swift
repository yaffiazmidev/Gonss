//
//  CheckoutResult.swift
//  KipasKipas
//
//  Created by PT.Koanba on 11/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

// MARK: - CheckoutOrderModel
struct CheckoutOrderResult: Codable {
    let code, message: String?
    let data: CheckoutOrderResponse?
}

// MARK: - DataClass
struct CheckoutOrderResponse: Codable {
    let redirectURL: String?
    let token: String?

    enum CodingKeys: String, CodingKey {
        case redirectURL = "redirectUrl"
        case token
    }
}

struct CheckoutOrderContinueResult: Codable {
    let message: String?
    let data: CheckoutOrderContinueResponse?
    let code: String?
}

struct CheckoutOrderContinueResponse: Codable {
    let token: String
    let redirectUrl: String
}

// MARK: -On ERROR
struct CheckoutOrderErrorResponse: Codable, Error {
    let message: String
    let data: String?
    let code: String
}

// MARK: - MessagePushNotifShopDto
struct MessagePushNotifShopDto: Codable {
    let notifFrom, notifShopType, accountShopType, text: String?
    let userTargetNotifIDS: [String]?
    let photo: String?
    let targetShopID: String?

    enum CodingKeys: String, CodingKey {
        case notifFrom, notifShopType, accountShopType, text
        case userTargetNotifIDS = "userTargetNotifIds"
        case photo
        case targetShopID = "targetShopId"
    }
}

// MARK: - MidtransSnapTokenDto
struct MidtransSnapTokenDto: Codable {
    let token: String?
    let redirectURL: String?

    enum CodingKeys: String, CodingKey {
        case token
        case redirectURL = "redirectUrl"
    }
}
