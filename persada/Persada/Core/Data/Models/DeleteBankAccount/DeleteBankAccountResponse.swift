//
//  DeleteBankAccountResponse.swift
//
//  Created by Yaffi Azmi on 26/10/21
//  Copyright (c) KOANBA. All rights reserved.
//

import Foundation

class DeleteBankAccountResponse: Codable {
  let code: String?
  let message: String?
  let data: DeleteBankAccountResponseData?
}
