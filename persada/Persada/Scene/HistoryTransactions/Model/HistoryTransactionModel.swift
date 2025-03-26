//
//  HistoryTransactionCellViewModel.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class HistoryTransactionModel {
    let date: Int
    let currency: Int
    let historyType: String
    let activityType: String
    let noInvoice: String?
    let orderId: String?
    let bankFee: Int?
    let bankAccountName: String?
    let bankAccountNumber: String?
    let bankName: String?
    
    init(date: Int, currency: Int, historyType: String, noInvoice: String? = nil, activity: String, orderId: String? = nil, bankFee: Int? = nil, bankAccountName: String? = nil, bankAccountNumber: String? = nil, bankName: String? = nil) {
        self.date = date
        self.currency = currency
        self.historyType = historyType
        self.activityType = activity
        self.noInvoice = noInvoice
        self.orderId = orderId
        self.bankFee = bankFee
        self.bankAccountName = bankAccountName
        self.bankAccountNumber = bankAccountNumber
        self.bankName = bankName
    }
}
