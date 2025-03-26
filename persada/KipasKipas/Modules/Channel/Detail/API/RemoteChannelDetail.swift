//
//  RemoteChannelDetail.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteChannelDetail: Codable {
    
  var code: String?
  var name: String?
  var id: String?
  var createAt: Int?
  var photo: String?
  var description: String?
  var isFollow: Bool?
}
