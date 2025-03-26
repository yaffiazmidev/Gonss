//
//  Ext-Member.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 31/07/23.
//

import Foundation
import SendbirdChatSDK

extension Array where Element == Member {
    public func firstMemberExcludingCurrentUser() -> Member? {
        let currentUserID = SendbirdChat.getCurrentUser()?.userId
        return self.first { $0.userId != currentUserID }
    }
    
    public func patner() -> Member? {
        let currentUserID = SendbirdChat.getCurrentUser()?.userId
        return self.first { $0.userId != currentUserID }
    }
}
