//
//  AddAccountBankResponse.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class ListBankResponse: Codable {
    var content: [Content?]
    var totalPages: Int?
    var last: Bool?
    
    class Content: Codable {
        let id: String?
        let code: String?
        let name: String?
        let bankCode: String?
        
        enum CodingKeys: String, CodingKey {
            case id, code, name
            case bankCode = "swiftCode"
        }
    }
}

class CheckBankAccountResponse: Codable {
    let bankCode: String?
    let accountNumber: String?
    let accountName: String?
    let bankName: String?
    
    enum CodingKeys: String, CodingKey {
        case bankCode = "beneficiary_bank_code"
        case accountNumber = "beneficiary_account_number"
        case accountName = "beneficiary_account_name"
        case bankName = "beneficiary_bank_name"
    }
}

struct AddAccountBankResponse: Codable {
    let message: String
    let data: BankData
    let code: String
}


// MARK: - BankData
struct BankData: Codable {
    let withdrawFee: Int
    let account: Profile?
    let id: String
    let bank: Bank
    let accountName, accountNumber: String
}


// MARK: - Bank
struct Bank: Codable {
    let refCode, createBy, id: String
    let isDeleted: Bool
    let modifyBy, modifyAt: String?
    let code, sandiBi: String?
    let swiftCode, createAt: String
    let name: String
}
