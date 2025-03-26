//
//  RemoteWithdrawalDiamond.swift
//  KipasKipasDirectMessage
//
//  Created by Muhammad Noor on 18/09/23.
//

import Foundation

public struct RemoteWithdrawalDiamond: Codable {
    public let code: String?
    public let message: String?
    public let data: WithdrawalDiamond?
}

public struct WithdrawalDiamond: Codable {
    public let id: String?
    public let bankAccountId: String?
    public let bankAccountName: String?
    public let bankAccountNumber: String?
    public let bankAccountFee: Int?
    public let qty: Int?
    public let conversionPerUnit: Int?
    public let amount: Int?
    public let balanceBefore: Int?
    public let balanceAfter: Int?
    public let transactionId: String?
    public let historyId: String?
}
