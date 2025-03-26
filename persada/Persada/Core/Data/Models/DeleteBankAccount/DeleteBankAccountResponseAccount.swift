//
//  DeleteBankAccountResponseAccount.swift
//
//  Created by Yaffi Azmi on 26/10/21
//  Copyright (c) KOANBA. All rights reserved.
//

import Foundation

struct DeleteBankAccountResponseAccount: Codable {
  var isSeller: Bool?
  var gender: String?
  var isDisabled: Bool?
  var email: String?
  var username: String?
  var bio: String?
  var id: String?
  var isVerified: Bool?
  var name: String?
  var photo: String?
  var accountType: String?
  var mobile: String?
}
