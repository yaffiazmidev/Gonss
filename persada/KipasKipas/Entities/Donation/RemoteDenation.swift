//
//  RemoteDonation.swift
//
//  Created by DENAZMI on 06/02/23
//  Copyright (c) . All rights reserved.
//

import Foundation

struct RemoteDonation: Codable {
    
    var code: String?
    var message: String?
    var data: RemoteDonationData?
}

struct RemoteDonationData: Codable {
    
    var first: Bool?
    var empty: Bool?
    var sort: RemoteDonationSort?
    var totalPages: Int?
    var content: [RemoteDonationContent]?
    var pageable: RemoteDonationPageable?
    var size: Int?
    var totalElements: Int?
    var number: Int?
    var last: Bool?
    var numberOfElements: Int?
}

struct RemoteDonationContent: Codable {
    
    var recipientName: String?
    var longitude: Float?
    var province: RemoteDonationProvince?
    var amountWithdraw: Double?
    var initiator: RemoteDonationInitiator?
    var id: String?
    var description: String?
    var createAt: Int?
    var status: String?
    var amountCollected: Double?
    var amountCollectedAdminFee: Double?
    var amountCollectedPercent: Float {
        return Float(Double(amountCollected ?? 0.0) / Double(targetAmount ?? 0.0))
    }
    var withdrawaAllowed: Bool?
    var donationCategory: RemoteDonationDonationCategory?
    //    var hashtags: Any?
    var latitude: Float?
    var title: String?
    var targetAmount: Double?
    var medias: [RemoteDonationMedias]?
    var amountAvailable: Double?
    var expiredAt: Int?
}

struct RemoteDonationDonationCategory: Codable {
    
    var icon: String?
    var name: String?
    var id: String?
}

struct RemoteDonationInitiator: Codable {
    
    var photo: String?
    var id: String?
    var name: String?
    var username: String?
    var isSeller: Bool?
    var isDisabled: Bool?
    
}

struct RemoteDonationMedias: Codable {
    
    var url: String?
    var metadata: RemoteDonationMetadata?
    var id: String?
    var thumbnail: RemoteDonationThumbnail?
    var type: String?
}

struct RemoteDonationMetadata: Codable {
    
    var size: String?
    var width: String?
    var height: String?
}

struct RemoteDonationPageable: Codable {
    
    var pageNumber: Int?
    var pageSize: Int?
    var sort: RemoteDonationSort?
    var unpaged: Bool?
    var offset: Int?
    var paged: Bool?
}

struct RemoteDonationProvince: Codable {
    
    var id: String?
    var name: String?
    var code: String?
}

struct RemoteDonationSort: Codable {
    
    var unsorted: Bool?
    var sorted: Bool?
    var empty: Bool?
}

struct RemoteDonationThumbnail: Codable {
    
    var medium: String?
    var large: String?
    var small: String?
}
