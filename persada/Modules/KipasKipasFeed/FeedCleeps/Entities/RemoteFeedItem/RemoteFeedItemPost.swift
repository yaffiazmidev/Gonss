//
//  RemoteFeedItemPost.swift
//
//  Created by DENAZMI on 04/10/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct RemoteFeedItemDonationCategory: Codable {
    enum CodingKeys: String, CodingKey {
      case id
      case name
    }
    
    public var id: String?
    public var name: String?
    
    
    public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    name = try container.decodeIfPresent(String.self, forKey: .name)
  }
}

public struct RemoteFeedItemPost: Codable {

  enum CodingKeys: String, CodingKey {
    case hashtags
    case type
    case descriptionValue = "description"
    case isScheduled
    case medias
    case status
    case channel
    case floatingLink
    case floatingLinkLabel
    case siteName
    case siteLogo
    case id
    case title
    case targetAmount
    case amountCollected
    case donationCategory
    case product
    case localRanks
    case levelPriority
    case isDonationItem
  }

    public var hashtags: [RemoteFeedItemHashtag]?
    public var type: String?
    public var descriptionValue: String?
    public var isScheduled: Bool?
    public var medias: [RemoteFeedItemMedias]?
    public var status: String?
    public var channel: RemoteFeedItemChannel?
    public var floatingLink: String?
    public var floatingLinkLabel: String?
    public var siteName: String?
    public var siteLogo: String?
    public var id: String?
    public var title: String?
    public var targetAmount: Double?
    public var amountCollected: Double?
    public var donationCategory: RemoteFeedItemDonationCategory?
    public var product: RemoteFeedItemProduct?
    public var localRanks: [RemoteDonateLocalRank]?
    public let levelPriority: Int?
    public let isDonationItem: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hashtags = try container.decodeIfPresent([RemoteFeedItemHashtag].self, forKey: .hashtags)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        descriptionValue = try container.decodeIfPresent(String.self, forKey: .descriptionValue)
        isScheduled = try container.decodeIfPresent(Bool.self, forKey: .isScheduled)
        medias = try container.decodeIfPresent([RemoteFeedItemMedias].self, forKey: .medias)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        channel = try container.decodeIfPresent(RemoteFeedItemChannel.self, forKey: .channel)
        floatingLink = try container.decodeIfPresent(String.self, forKey: .floatingLink)
        floatingLinkLabel = try container.decodeIfPresent(String.self, forKey: .floatingLinkLabel)
        siteName = try container.decodeIfPresent(String.self, forKey: .siteName)
        siteLogo = try container.decodeIfPresent(String.self, forKey: .siteLogo)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        targetAmount = try container.decodeIfPresent(Double.self, forKey: .targetAmount)
        amountCollected = try container.decodeIfPresent(Double.self, forKey: .amountCollected)
        donationCategory = try container.decodeIfPresent(RemoteFeedItemDonationCategory.self, forKey: .donationCategory)
        product = try container.decodeIfPresent(RemoteFeedItemProduct.self, forKey: .product)
        localRanks = try container.decodeIfPresent([RemoteDonateLocalRank].self, forKey: .localRanks)
        levelPriority = try container.decodeIfPresent(Int.self, forKey: .levelPriority)
        isDonationItem = try container.decodeIfPresent(Bool.self, forKey: .isDonationItem)
    }
    
    public static func == (lhs: RemoteFeedItemPost, rhs: RemoteFeedItemPost) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct RemoteFeedItemProduct: Codable {
    
    public var accountId: String?
    public var description: String?
    public var generalStatus: String?
    public var id: String?
    public var isDeleted: Bool?
    public var measurement: RemoteFeedItemProductMeasurement?
    public var medias: [RemoteFeedItemMedias]?
    public var name: String?
    public var price: Double?
    public var sellerName: String?
    public var sold: Bool?
    public var productPages: String?
    public var reasonBanned: String?
}

public struct RemoteFeedItemProductMeasurement: Codable {
    public var weight, length, height, width: Double?
}


public struct RemoteDonateLocalRank: Codable {
    public let id: String?
    public let localRank: Int?
    public let name: String?
    public let url: String?
    public let account: RemoteFeedItemAccount?
    public let totalLocalDonation: Int?
}
