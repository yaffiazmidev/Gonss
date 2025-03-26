//
//  RemoteCurrencyHistoryDetailData.swift
//
//  Created by DENAZMI on 11/09/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteCurrencyHistoryDetailData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case invoiceNumber
        case accountNumber
        case storeName
        case totalAmount
        case id
        case conversionPerUnit
        case bankFee
        case recipient
        case accountName
        case createAt
        case qty
        case currencyType
        case bankName
        case userName
    }
    
    public var invoiceNumber: String?
    public var accountNumber: String?
    public var storeName: String?
    public var totalAmount: Double?
    public var id: String?
    public var conversionPerUnit: Double?
    public var bankFee: Double?
    public var recipient: String?
    public var accountName: String?
    public var createAt: String?
    public var qty: Int?
    public var currencyType: String?
    public var bankName: String?
    public var userName: String?
    
    public init(invoiceNumber: String?, accountNumber: String?, storeName: String?, totalAmount: Double?, id: String?, conversionPerUnit: Double?, bankFee: Double?, recipient: String?, accountName: String?, createAt: String?, qty: Int?, currencyType: String?, bankName: String?, userName: String?) {
        self.invoiceNumber = invoiceNumber
        self.accountNumber = accountNumber
        self.storeName = storeName
        self.totalAmount = totalAmount
        self.id = id
        self.conversionPerUnit = conversionPerUnit
        self.bankFee = bankFee
        self.recipient = recipient
        self.accountName = accountName
        self.createAt = createAt
        self.qty = qty
        self.currencyType = currencyType
        self.bankName = bankName
        self.userName = userName
    }
    
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        invoiceNumber = try container.decodeIfPresent(String.self, forKey: .invoiceNumber)
        accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
        storeName = try container.decodeIfPresent(String.self, forKey: .storeName)
        totalAmount = try container.decodeIfPresent(Double.self, forKey: .totalAmount)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        conversionPerUnit = try container.decodeIfPresent(Double.self, forKey: .conversionPerUnit)
        bankFee = try container.decodeIfPresent(Double.self, forKey: .bankFee)
        recipient = try container.decodeIfPresent(String.self, forKey: .recipient)
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
        createAt = try container.decodeIfPresent(String.self, forKey: .createAt)
        qty = try container.decodeIfPresent(Int.self, forKey: .qty)
        currencyType = try container.decodeIfPresent(String.self, forKey: .currencyType)
        bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
    }
    
}
