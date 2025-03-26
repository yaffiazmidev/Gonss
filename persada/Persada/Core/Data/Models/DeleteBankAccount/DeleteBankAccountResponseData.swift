//
//  DeleteBankAccountResponseData.swift
//
//  Created by Yaffi Azmi on 26/10/21
//  Copyright (c) KOANBA. All rights reserved.
//

import Foundation

class DeleteBankAccountResponseData: Codable {
//  var bank: DeleteBankAccountResponseBank?
//  var account: DeleteBankAccountResponseAccount?
  let id: String?
  let accountName: String?
  let accountNumber: String?
  let withdrawFee: Int?
}
