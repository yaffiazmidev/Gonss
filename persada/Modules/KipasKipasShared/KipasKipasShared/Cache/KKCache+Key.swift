//
//  KKCache+Key.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/11/23.
//

import Foundation

public extension KKCache.Key {
    static let trendingCache = KKCache.Key("trendingCache")
    static let loggedInUser = KKCache.Key("loggedInUser")
    static let profile = KKCache.Key("profile")
    static let newsPortalVersion = KKCache.Key("newsPortalVersion")
    static let newsPortalQuickAccess = KKCache.Key("newsPortalQuickAccess")
    static let diamond = KKCache.Key("diamond")   // DM 
    static let coin = KKCache.Key("coin")
    static let liveDiamondAmount = KKCache.Key("liveDiamondAmount") 
    static let idrAmount = KKCache.Key("idrAmount")
    static let consumptionGrade = KKCache.Key("consumptionGrade")
    static let lackPoints = KKCache.Key("lackPoints")
    static let topSeatsCache = KKCache.Key("topSeatsCache")
    static let roomInfoCache = KKCache.Key("roomInfoCache")
    static let baseURL = KKCache.Key("baseURL")
    static let enablePushCall = KKCache.Key("enablePushCall")
    static let swipeGuideShowed = KKCache.Key("swipeGuideShowed")
    static let userId = KKCache.Key("userId")
    static let userPhotoProfile = KKCache.Key("userPhotoProfile")
    static let verifyIdentity = KKCache.Key("verifyIdentityEmail")

    static func unreadNotificationCount(_ id: String) -> KKCache.Key { KKCache.Key("unreadNotificationCount-\(id)") }
}
