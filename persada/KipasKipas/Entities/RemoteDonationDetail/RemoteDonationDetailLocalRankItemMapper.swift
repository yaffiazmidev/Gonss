//
//  RemoteDonationDetailLocalRankItemMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 25/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

struct RemoteDonationDetailLocalRank: Codable {
    let code: String?
    let message: String?
    let data: DonationDetailLocalRankData?
}

struct DonationDetailLocalRankData: Codable {
    let content: [DonationDetailLocalRankContent]?
}

struct DonationDetailLocalRankContent: Codable {
    let id: String?
    let localRank: Int?
    let globalRank: String?
    let name: String?
    let url: String?
    let statusRank: String?
    let account: DonationDetailLocalRankAccount?
    let totalLocalDonation: Int?
}

struct DonationDetailLocalRankAccount: Codable {
    let id: String?
    let username: String?
    let name: String?
    let photo: String?
    let isVerified: Bool?
    let totalDonation: Int?
    let levelBadge: Int?
    let donationBadgeid: String?
    let urlBadge: String?
    let isShowBadge: Bool?
}

struct LocalRankItem {
    let id: String
    let name: String
    let username: String
    let photo: String
    let isVerified: Bool
    let localRank: Int
    let levelBadge: Int
    let urlBadge: String
    let totalDonation: Int
    let isShowBadge: Bool
}

