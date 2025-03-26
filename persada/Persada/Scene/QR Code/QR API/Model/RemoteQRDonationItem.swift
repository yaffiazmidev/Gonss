//
//  RemoteQRDonationItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - RemoteQRDonationItemRoot
struct RemoteQRDonationItemRoot: Codable {
    let code, message: String?
    let data: RemoteQRDonationItem?
}

// MARK: - RemoteQRDonationItem
struct RemoteQRDonationItem: Codable {
    let id: String?
    let medias: [RemoteQRDonationMediaItem]?
    let description, title: String?
    let targetAmount: Int?
    let recipientName, status: String?
    let amountCollected, amountWithdraw, createAt, expiredAt: Int?
    let initiator: RemoteQRDonationInitiatorItem?
    let donationCategory: RemoteQRDonationDonationCategoryItem?
    let latitude, longitude: Double?
    let province: RemoteQRDonationProvinceItem?
    let amountAvailable: Double?
    let withdrawaAllowed: Bool?
}

// MARK: - DonationCategory
struct RemoteQRDonationDonationCategoryItem: Codable {
    let id: String?
    let icon: String?
    let name: String?
}

// MARK: - Initiator
struct RemoteQRDonationInitiatorItem: Codable {
    let id, username, name: String?
    let bio, photo, birthDate: String?
    let gender: String?
    let isFollow, isSeleb: Bool?
    let mobile, email, accountType: String?
    let isVerified: Bool?
    let note: String?
    let isDisabled: Bool?
    let isSeller: Bool?
}

// MARK: - Media
struct RemoteQRDonationMediaItem: Codable {
    let id, type: String?
    let url: String?
    let thumbnail: RemoteQRDonationThumbnailItem?
    let metadata: RemoteQRDonationMetadataItem?
    let isHLSReady: Bool?
    let hlsURL: String?
}

// MARK: - Metadata
struct RemoteQRDonationMetadataItem: Codable {
    let width, height, size: String?
    let duration: Double?
}

// MARK: - Thumbnail
struct RemoteQRDonationThumbnailItem: Codable {
    let large, medium, small: String?
}

// MARK: - Province
struct RemoteQRDonationProvinceItem: Codable {
    let id: String?
    let createBy, createAt, modifyBy, modifyAt: Double?
    let isDeleted: Bool?
    let code, name: String?
}
