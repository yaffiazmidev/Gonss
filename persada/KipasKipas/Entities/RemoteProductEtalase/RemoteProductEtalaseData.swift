//
//  RemoteProductEtalaseData.swift
//
//  Created by DENAZMI on 05/01/24
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteProductEtalaseData: Codable {

  enum CodingKeys: String, CodingKey {
    case descriptionValue = "description"
    case city
    case sellerName
    case name
    case isDeleted
    case priceAfterDiscount
    case generalStatus
    case medias
    case isResellerAllowed
    case measurement
    case cashbacklabel
    case isBanned
    case accountId
    case productCategoryName
    case id
    case type
    case stock
    case totalSales
    case productCategoryId
    case price
    case discount
    case ratingAverage
  }

  var descriptionValue: String?
  var city: String?
  var sellerName: String?
  var name: String?
  var isDeleted: Bool?
  var priceAfterDiscount: Int?
  var generalStatus: String?
  var medias: [RemoteProductEtalaseMedias]?
  var isResellerAllowed: Bool?
  var measurement: RemoteProductEtalaseMeasurement?
  var cashbacklabel: String?
  var isBanned: Bool?
  var accountId: String?
  var productCategoryName: String?
  var id: String?
  var type: String?
  var stock: Int?
  var totalSales: Int?
  var productCategoryId: String?
  var price: Double?
  var discount: Int?
  var ratingAverage: Int?



  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
    city = try container.decodeIfPresent(String.self, forKey: .city)
    sellerName = try container.decodeIfPresent(String.self, forKey: .sellerName)
    name = try container.decodeIfPresent(String.self, forKey: .name)
    isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
    priceAfterDiscount = try container.decodeIfPresent(Int.self, forKey: .priceAfterDiscount)
    generalStatus = try container.decodeIfPresent(String.self, forKey: .generalStatus)
    medias = try container.decodeIfPresent([RemoteProductEtalaseMedias].self, forKey: .medias)
    isResellerAllowed = try container.decodeIfPresent(Bool.self, forKey: .isResellerAllowed)
    measurement = try container.decodeIfPresent(RemoteProductEtalaseMeasurement.self, forKey: .measurement)
    cashbacklabel = try container.decodeIfPresent(String.self, forKey: .cashbacklabel)
    isBanned = try container.decodeIfPresent(Bool.self, forKey: .isBanned)
    accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
    productCategoryName = try container.decodeIfPresent(String.self, forKey: .productCategoryName)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    stock = try container.decodeIfPresent(Int.self, forKey: .stock)
    totalSales = try container.decodeIfPresent(Int.self, forKey: .totalSales)
    productCategoryId = try container.decodeIfPresent(String.self, forKey: .productCategoryId)
    price = try container.decodeIfPresent(Double.self, forKey: .price)
    discount = try container.decodeIfPresent(Int.self, forKey: .discount)
    ratingAverage = try container.decodeIfPresent(Int.self, forKey: .ratingAverage)
  }

}
