//
//  RemoteDonationOrderDetailData.swift
//
//  Created by DENAZMI on 01/03/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationOrderDetailData: Codable {

  enum CodingKeys: String, CodingKey {
    case orderDetail
    case id
  }

  var orderDetail: RemoteDonationOrderDetailOrderDetail?
  var id: String?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    orderDetail = try container.decodeIfPresent(RemoteDonationOrderDetailOrderDetail.self, forKey: .orderDetail)
    id = try container.decodeIfPresent(String.self, forKey: .id)
  }

}
