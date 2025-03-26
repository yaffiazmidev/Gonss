//
//  RemoteDonationWithdraw.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteDonationWithdrawGopay: Codable {
    let code, message: String?
    let data: RemoteDonationWithdrawGopayData?
}

struct RemoteDonationWithdrawGopayData: Codable {
    let payouts: [RemoteDonationWithdrawGopayPayout]?
}

struct RemoteDonationWithdrawGopayPayout: Codable {
    let status: String?
    let reference_no: String?
}

struct RemoteDonationWithdrawBank: Codable {
    let code, message: String?
    let data: RemoteDonationWithdrawBankData?
}

struct RemoteDonationWithdrawBankData: Codable {
    let id: String?
}
