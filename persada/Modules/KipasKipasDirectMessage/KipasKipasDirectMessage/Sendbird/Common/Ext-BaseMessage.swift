//
//  Ext-BaseMessage.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 28/07/23.
//

import Foundation
import SendbirdChatSDK

extension BaseMessage {
    public func isSender() -> Bool {
        return sender?.userId == SendbirdChat.getCurrentUser()?.userId
    }
    
    public func type() -> String {
        if let fileMessage = self as? FileMessage {
            return fileMessage.type.hasPrefix("image") == true ? "image" : "video"
        }
        return "message"
    }
    
    public var mediaThumbnailURL: URL? {
        get {
            guard let fileMessage = self as? FileMessage else {
                return nil
            }
            
            if let thumbnailURLString = fileMessage.thumbnails?.first?.url {
                return URL(string: thumbnailURLString)
            } else if fileMessage.type.hasPrefix("image") {
                return URL(string: fileMessage.url)
            }
            
            return nil
        }
    }
    
    public var mediaURL: URL? {
        get {
            guard let fileMessage = self as? FileMessage else {
                return nil
            }
            
            return URL(string: fileMessage.url)
        }
    }
}

extension FileMessage {
    
    public var thumbnailURL: URL? {
        get {
            if let thumbnailURLString = thumbnails?.first?.url {
                return URL(string: thumbnailURLString)
            } else if type.hasPrefix("image") {
                return URL(string: url)
            }
            
            return nil
        }
    }
    
    public var isVideo: Bool {
        get {
            return !type.hasPrefix("image")
        }
    }
}
