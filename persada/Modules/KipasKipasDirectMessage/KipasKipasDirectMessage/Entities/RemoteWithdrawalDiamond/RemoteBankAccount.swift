//
//  RemoteBankAccount.swift
//  KipasKipasDirectMessage
//
//  Created by Muhammad Noor on 18/09/23.
//

import Foundation

// MARK: - RemoteBankAccount
public struct RemoteBankAccount: Codable {
    public let code, message: String?
    public let data: BankData?
}

// MARK: - BankData
public struct BankData: Codable {
    public let bank, gopay: [Banks]?
}

// MARK: - Banks
public struct Banks: Codable {
    public let bank: Bank?
    public let id, accountName, accountNumber: String?
    public let withdrawFee: Int?
    public let amountWithdrawFee: Int?
}

// MARK: - Bank
public struct Bank: Codable {
    public let id, createBy, createAt: String?
    public let isDeleted: Bool?
    public let code: String?
    public let refCode, name: String?
    public let sandiBi: String?
    public let swiftCode: String?
}
