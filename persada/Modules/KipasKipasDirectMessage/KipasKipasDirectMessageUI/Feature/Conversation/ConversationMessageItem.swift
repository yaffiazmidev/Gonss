//
//  ConversationMessageItem.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 31/08/23.
//

import UIKit

enum MessageSendingStatus: Int {
    case none = 0

    /// Indicates the status of the message returned when trying to send a message.
    /// The message with the pending status means that is not dispatched completely to the Sendbird
    /// server. The pending message should be replaced with a message (failed or succeeded)
    /// from the callback.
    case pending = 1

    /// Indicates the status of the message that failed to send the message.
    case failed = 2

    /// Indicates the status of the message that success to send the message.
    case succeeded = 3

    /// Indicates the status of the message that is canceled.
    case canceled = 4

    /// Indicates the status of the message that is scheduled.
    case scheduled = 5
}

struct ConversationMessageItem {
    let messageId: String
    let message: String
    let createdAt: Date
    let isSender: Bool
    let sendingStatus: MessageSendingStatus
    let type: String
    let media: ConversationMessageMedia?
    let data: ConversationMessageData?
}

struct ConversationMessageMedia {
    let url: URL?
    let thumbnail: URL?
    let type: String
    let tempThumbnail: UIImage?
    let tempData: Data?
}

struct ConversationMessageData: Codable {
    let isPaid: Bool?
    let messageId: String?
    let product: ConversationMessageDataProduct?
    let status: String?
    let chatPrice: Int?
}

struct ConversationMessageDataProduct: Codable {
    let accountId: String?
    let city: String?
    let commission: Double?
    let description: String?
    let generalStatus: String?
    let id: String?
    let isBanned: Bool?
    let isDeleted: Bool?
    let isResellerAllowed: Bool?
    let measurement: ConversationMessageDataProductMeasurement?
    let medias: [ConversationMessageDataProductMedia]?
    let modal: Double?
    let name: String?
    let price: Double?
    let productCategoryId: String?
    let productCategoryName: String?
    let ratingAverage: Double?
    let sellerName: String?
    let stock: Int?
    let totalSales: Int?
    let type: String?
}

struct ConversationMessageDataProductMeasurement: Codable {
    let height: Int?
    let length: Int?
    let weight: Double?
    let width: Int?
}

struct ConversationMessageDataProductMedia: Codable {
    let id: String?
    let metadata: ConversationMessageDataProductMediaMetadata?
    let thumbnail: ConversationMessageDataProductMediaThumbnail?
    let type: String?
    let url: String?
}

struct ConversationMessageDataProductMediaMetadata: Codable {
    let height: String?
    let size: String?
    let width: String?
}

struct ConversationMessageDataProductMediaThumbnail: Codable {
    let large: String?
    let medium: String?
    let small: String?
}

