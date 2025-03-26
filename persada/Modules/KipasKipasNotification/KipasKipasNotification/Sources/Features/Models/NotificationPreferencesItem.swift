//
//  NotificationPreferencesItem.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation

public struct NotificationPreferencesItem {
    public var socialmedia: Bool
    public var socialMediaComment: Bool
    public var socialMediaLike: Bool
    public var socialMediaMention: Bool
    public var socialMediaFollower: Bool
    public var socialMediaLive: Bool
    public var socialMediaAccount: Bool
    
    public init(
        socialmedia: Bool = false,
        socialMediaComment: Bool = false,
        socialMediaLike: Bool = false,
        socialMediaMention: Bool = false,
        socialMediaFollower: Bool = false,
        socialMediaLive: Bool = false,
        socialMediaAccount: Bool = false
    ) {
        self.socialmedia = socialmedia
        self.socialMediaComment = socialMediaComment
        self.socialMediaLike = socialMediaLike
        self.socialMediaMention = socialMediaMention
        self.socialMediaFollower = socialMediaFollower
        self.socialMediaLive = socialMediaLive
        self.socialMediaAccount = socialMediaAccount
    }
    
    public mutating func setAll(isOn: Bool) {
        self.socialMediaComment = isOn
        self.socialMediaLike = isOn
        self.socialMediaMention = isOn
        self.socialMediaFollower = isOn
    }
    
    public var allTrue: Bool {
        let mirror = Mirror(reflecting: self)
        return mirror.children.allSatisfy { $0.value as? Bool == true }
    }
}
