//
//  MessageSendingStatus.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 20/07/23.
//

import Foundation
import SendbirdChatSDK

public struct MessageSendingStatus {
    
    public let description: String
    
    public init(_ rawValue: BaseMessage) {
        switch rawValue.sendingStatus {
        case .pending:
            description = "(pending)"
        case .failed:
            description = "(failed)"
        case .succeeded:
            description = ""
        case .canceled:
            description = "(canceled)"
        default:
            description = ""
        }
    }
    
}
