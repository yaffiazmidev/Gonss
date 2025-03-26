//
//  RemoteDonationDetailData.swift
//
//  Created by DENAZMI on 28/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonationDetailData: Codable {

  enum CodingKeys: String, CodingKey {
    case id
    case recipientName
    case title
    case targetAmount
    case latitude
    case initiator
    case amountCollected
    case expiredAt
    case longitude
    case comments
    case status
    case amountAvailable
    case createAt
    case province
    case descriptionValue = "description"
    case medias
    case withdrawaAllowed
    case type
    case amountWithdraw
    case donationCategory
    case feedId
    case amountCollectedAdminFee
    case isDonationItem, totalItem, totalItemCollected
  }

  var id: String?
  var recipientName: String?
  var title: String?
  var targetAmount: Double?
  var initiator: RemoteDonationDetailInitiator?
  var amountCollected: Double?
  var expiredAt: Int?
  var longitude: Double?
  var latitude: Double?
  var comments: Int?
  var status: String?
  var amountAvailable: Double?
  var createAt: Int?
  var province: RemoteDonationDetailProvince?
  var descriptionValue: String?
  var medias: [RemoteDonationDetailMedias]?
  var withdrawaAllowed: Bool?
  var type: String?
  var amountWithdraw: Double?
  var donationCategory: RemoteDonationDetailDonationCategory?
  var amountCollectedPercent: Float {
    return Float(Double(amountCollected ?? 0.0) / Double(targetAmount ?? 0.0))
  }
  var feedId: String?
  var amountCollectedAdminFee: Double?
    var amountWithdrawalPercent: Float {
        return Float((amountWithdraw ?? 0) / (amountCollected ?? 0))
    }
    
 // MARK: Donation Item
    let isDonationItem: Bool?
    let totalItem: Int?
    let totalItemCollected: Int?
    
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    recipientName = try container.decodeIfPresent(String.self, forKey: .recipientName)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    targetAmount = try container.decodeIfPresent(Double.self, forKey: .targetAmount)
    latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
    initiator = try container.decodeIfPresent(RemoteDonationDetailInitiator.self, forKey: .initiator)
    amountCollected = try container.decodeIfPresent(Double.self, forKey: .amountCollected)
    expiredAt = try container.decodeIfPresent(Int.self, forKey: .expiredAt)
    longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    comments = try container.decodeIfPresent(Int.self, forKey: .comments)
    status = try container.decodeIfPresent(String.self, forKey: .status)
    amountAvailable = try container.decodeIfPresent(Double.self, forKey: .amountAvailable)
    createAt = try container.decodeIfPresent(Int.self, forKey: .createAt)
    province = try container.decodeIfPresent(RemoteDonationDetailProvince.self, forKey: .province)
    descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
    medias = try container.decodeIfPresent([RemoteDonationDetailMedias].self, forKey: .medias)
    withdrawaAllowed = try container.decodeIfPresent(Bool.self, forKey: .withdrawaAllowed)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    amountWithdraw = try container.decodeIfPresent(Double.self, forKey: .amountWithdraw)
    donationCategory = try container.decodeIfPresent(RemoteDonationDetailDonationCategory.self, forKey: .donationCategory)
    feedId = try container.decodeIfPresent(String.self, forKey: .feedId)
    amountCollectedAdminFee = try container.decodeIfPresent(Double.self, forKey: .amountCollectedAdminFee)
    isDonationItem = try container.decodeIfPresent(Bool.self, forKey: .isDonationItem)
      totalItem = try container.decodeIfPresent(Int.self, forKey: .totalItem)
      totalItemCollected = try container.decodeIfPresent(Int.self, forKey: .totalItemCollected)
  }

}
