//
//  RemoteCheckGopayAccount.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteCheckGopayAccount: Codable {

  enum CodingKeys: String, CodingKey {
    case code
    case data
    case message
  }

  var code: String?
  var data: RemoteCheckGopayAccountData?
  var message: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    code = try container.decodeIfPresent(String.self, forKey: .code)
    data = try container.decodeIfPresent(RemoteCheckGopayAccountData.self, forKey: .data)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }

}

struct RemoteCheckGopayAccountData: Codable {

  enum CodingKeys: String, CodingKey {
    case accountNumber = "account_no"
    case accountName = "account_name"
    case bankName = "bank_name"
  }

  var accountNumber: String?
  var accountName: String?
  var bankName: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
      accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
      accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
      bankName = try container.decodeIfPresent(String.self, forKey: .bankName)
  }
}
