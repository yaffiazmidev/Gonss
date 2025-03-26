//
//  NotificationLotteryItem.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 25/07/24.
//

import Foundation

public struct NotificationLotteryItem {
    public let content: [NotificationLotteryContent]
    public var totalPages: Int
}

public struct NotificationLotteryContent {
    public let id: String
    public let actionType: String
    public let targetType: String
    public let actionMessage: String
    public let targetId: String
    
    public var title: String {
        switch targetType {
        case "undian_join":
            return "Berhasil mengikuti undian"
        case "undian_won":
            return "Selamat, kamu beruntung!"
        case "undian_lost":
            return "Belum beruntung"
        case "undian_expired":
            return "Maaf hadiahmu sudah kadaluarsa"
        default:
            return "Undian"
        }
    }
}
