//
//  MembersReadMessageUseCase.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 10/07/23.
//

import Foundation
import SendbirdChatSDK

open class MembersReadMessageUseCase {
    private let channel: GroupChannel
    
    public init(channel: GroupChannel) {
        self.channel = channel
    }
    
    open func getReadMembers(for message: BaseMessage) -> [Member] {
       return channel.getReadMembers(message: message, includeAllMembers: false)
    }
}
