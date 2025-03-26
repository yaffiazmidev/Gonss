//
//  QRDonationItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - QRDonationItem
struct QRDonationItem {
    
    let id: String?
    let medias: [QRDonationMediaItem]?
    let description, title: String?
    let targetAmount: Int?
    let recipientName, status: String?
    let amountCollected, amountWithdraw, createAt, expiredAt: Int?
    let initiator: QRDonationInitiatorItem?
    let donationCategory: QRDonationDonationCategoryItem?
    let latitude, longitude: Double?
    let province: QRDonationProvinceItem?
    let amountAvailable: Double?
    let withdrawaAllowed: Bool?
    
    init(id: String?, medias: [QRDonationMediaItem]?, description: String?, title: String?, targetAmount: Int?, recipientName: String?, status: String?, amountCollected: Int?, amountWithdraw: Int?, createAt: Int?, expiredAt: Int?, initiator: QRDonationInitiatorItem?, donationCategory: QRDonationDonationCategoryItem?, latitude: Double?, longitude: Double?, province: QRDonationProvinceItem?, amountAvailable: Double?, withdrawaAllowed: Bool?) {
        self.id = id
        self.medias = medias
        self.description = description
        self.title = title
        self.targetAmount = targetAmount
        self.recipientName = recipientName
        self.status = status
        self.amountCollected = amountCollected
        self.amountWithdraw = amountWithdraw
        self.createAt = createAt
        self.expiredAt = expiredAt
        self.initiator = initiator
        self.donationCategory = donationCategory
        self.latitude = latitude
        self.longitude = longitude
        self.province = province
        self.amountAvailable = amountAvailable
        self.withdrawaAllowed = withdrawaAllowed
    }
}

// MARK: - DonationCategory
struct QRDonationDonationCategoryItem {
    
    let id: String?
    let icon: String?
    let name: String?
    
    init(id: String?, icon: String?, name: String?) {
        self.id = id
        self.icon = icon
        self.name = name
    }
}

// MARK: - Initiator
struct QRDonationInitiatorItem {
    
    let id, username, name: String?
    let bio, photo, birthDate: String?
    let gender: String?
    let isFollow, isSeleb: Bool?
    let mobile, email, accountType: String?
    let isVerified: Bool?
    let note: String?
    let isDisabled: Bool?
    let isSeller: Bool?
    
    init(id: String?, username: String?, name: String?, bio: String?, photo: String?, birthDate: String?, gender: String?, isFollow: Bool?, isSeleb: Bool?, mobile: String?, email: String?, accountType: String?, isVerified: Bool?, note: String?, isDisabled: Bool?, isSeller: Bool?) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
    }
}

// MARK: - Media
struct QRDonationMediaItem {
    
    let id, type: String?
    let url: String?
    let thumbnail: QRDonationThumbnailItem?
    let metadata: QRDonationMetadataItem?
    let isHLSReady: Bool?
    let hlsURL: String?
    
    init(id: String?, type: String?, url: String?, thumbnail: QRDonationThumbnailItem?, metadata: QRDonationMetadataItem?, isHLSReady: Bool?, hlsURL: String?) {
        self.id = id
        self.type = type
        self.url = url
        self.thumbnail = thumbnail
        self.metadata = metadata
        self.isHLSReady = isHLSReady
        self.hlsURL = hlsURL
    }
}

// MARK: - Metadata
struct QRDonationMetadataItem {
    
    let width, height, size: String?
    let duration: Double?
    
    init(width: String?, height: String?, size: String?, duration: Double?) {
        self.width = width
        self.height = height
        self.size = size
        self.duration = duration
    }
}

// MARK: - Thumbnail
struct QRDonationThumbnailItem {
    
    let large, medium, small: String?
    
    init(large: String?, medium: String?, small: String?) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}

// MARK: - Province
struct QRDonationProvinceItem {
    
    let id: String?
    let createBy, createAt, modifyBy, modifyAt: Double?
    let isDeleted: Bool?
    let code, name: String?
    
    init(id: String?, createBy: Double?, createAt: Double?, modifyBy: Double?, modifyAt: Double?, isDeleted: Bool?, code: String?, name: String?) {
        self.id = id
        self.createBy = createBy
        self.createAt = createAt
        self.modifyBy = modifyBy
        self.modifyAt = modifyAt
        self.isDeleted = isDeleted
        self.code = code
        self.name = name
    }
}
