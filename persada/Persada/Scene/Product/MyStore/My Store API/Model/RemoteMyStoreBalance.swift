//
//  RemoteMyStoreBalance.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - RemoteBalanceRoot
struct RemoteMyStoreBalance: Codable {
    let code, message: String?
    let data: RemoteMyStoreBalanceData?
}

// MARK: - RemoteBalanceData
struct RemoteMyStoreBalanceData: Codable {
    let id: String?
    let transactionBalance: Double?
    let refundBalance: Double?
    let totalBalance: Double?
    let isGopayActive: Bool?
    let gopayBalance: Double?
    let accountId: String?
    let withdrawFee: Double?
    let bankAccountDto: String?
    let postDonationId: String?
}
