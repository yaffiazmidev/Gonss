//
//  RemoteCurrencyConverter.swift
//  KipasKipasDirectMessage
//
//  Created by Muhammad Noor on 18/09/23.
//

import Foundation

public struct RemoteCurrencyConverter: Codable {
    public let code, message: String?
    public let data: CurrencyConvert
   
}

public struct CurrencyConvert: Codable {
    public let unitPrice, totalPrice: Int?
}
