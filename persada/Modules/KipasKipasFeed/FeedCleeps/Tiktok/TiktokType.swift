//
//  CleepsType.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/01/23.
//

import Foundation

public enum TiktokType: Equatable {
    case profile(isSelf: Bool)
    case feed
    case following
    case cleeps(country: CleepsCountry)
    case trending
    case channelContents
    case explore
    case search
    case pushNotif
    case notif
    case hashtag(tag: String)
    case donation
    
    public var rawValue: String {
        switch self {
        case .profile(let isSelf): return "PROFILE_\(isSelf ? "SELF" : "OTHER")"
        case .feed: return "FEED"
        case .following: return "FOLLOWING"
        case .cleeps(let country): return "CLEEPS_\(country.tag)"
        case .trending: return "TRENDING"
        case .channelContents: return "CHANNEL_CONTENTS"
        case .explore: return "EXPLORE"
        case .search: return "SEARCH"
        case .pushNotif: return "PUSH_NOTIFICATION"
        case .notif: return "NOTIFICATION"
        case .hashtag(let tag): return "HASHTAG_\(tag)"
        case .donation: return "DONATION"
        }
    }
    
    var isLinearFromZero: Bool {
        switch self {
        case .profile(_): return false
        case .feed: return true
        case .following: return true
        case .cleeps(_): return true
        case .trending: return true
        case .channelContents: return false
        case .explore: return false
        case .search: return false
        case .pushNotif: return true
        case .notif: return true
        case .hashtag(_): return false
        case .donation: return true
        }
    }
}
