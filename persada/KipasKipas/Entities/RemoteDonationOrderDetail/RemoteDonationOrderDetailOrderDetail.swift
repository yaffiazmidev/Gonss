//
//  RemoteDonationOrderDetailOrderDetail.swift
//
//  Created by DENAZMI on 01/03/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationOrderDetailOrderDetail: Codable {

  enum CodingKeys: String, CodingKey {
    case urlPaymentPage
  }

  var urlPaymentPage: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    urlPaymentPage = try container.decodeIfPresent(String.self, forKey: .urlPaymentPage)
  }

}
