//
//  Balance.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation


struct MyStoreBalance: Hashable{
    let id: String
    let transactionBalance: Double
    let refundBalance: Double
    let totalBalance: Double
    let isGopayActive: Bool
    let gopayBalance: Double
    let accountId: String
    let withdrawFee: Double?
    let bankAccountDto: String?
    let postDonationId: String?
    
    init(id: String, transactionBalance: Double, refundBalance: Double, totalBalance: Double, isGopayActive: Bool, gopayBalance: Double, accountId: String, withdrawFee: Double?, bankAccountDto: String?, postDonationId: String?) {
        self.id = id
        self.transactionBalance = transactionBalance
        self.refundBalance = refundBalance
        self.totalBalance = totalBalance
        self.isGopayActive = isGopayActive
        self.gopayBalance = gopayBalance
        self.accountId = accountId
        self.withdrawFee = withdrawFee
        self.bankAccountDto = bankAccountDto
        self.postDonationId = postDonationId
    }
}
