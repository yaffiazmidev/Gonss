//
//  WithdrawalBalanceResponse.swift
//  KipasKipas
//
//  Created by iOS Dev on 25/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class WithdrawalBalanceInfoResponse: Codable {
    let transactionBalance: Double?
    let refundBalance: Double?
    let totalBalance: Double?
    let withdrawFee: Double?
}

class ListBankAccountUserResponse: Codable {
    let id: String?
    let accountNumber: String?
    let accountName: String?
    let bank: Bank?
    let withdrawFee: Double?
    
    class Bank: Codable {
        let name: String?
        let swiftCode: String?
    }
}


