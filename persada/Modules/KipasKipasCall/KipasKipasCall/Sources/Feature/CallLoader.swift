//
//  CallLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation

public enum CallType {
    case video
    case audio
}

public enum IOSCallPushType {
    case apns
    case voIP
}

public struct CallLoaderRequest {
    public let roomId: String
    public let userId: String
    public let type: CallType
    public let timeOut: Int
    public let pushInfo: CallLoaderRequestPushInfo?
    
    public init(roomId: String, userId: String, type: CallType, timeOut: Int = 30, pushInfo: CallLoaderRequestPushInfo? = nil) {
        self.roomId = roomId
        self.userId = userId
        self.type = type
        self.timeOut = timeOut
        self.pushInfo = pushInfo
    }
}

public struct CallLoaderRequestPushInfo {
    public let title: String
    public let description: String
    public let iosPushType: IOSCallPushType
    public let ignoreIOSBadge: Bool
    public let iOSSound: String
    public let androidSound: String
    public let androidVIVOClassification: Int
    public let androidHuaWeiCategory: String
    
    public init(title: String, description: String, iosPushType: IOSCallPushType, ignoreIOSBadge: Bool, iOSSound: String, androidSound: String, androidVIVOClassification: Int, androidHuaWeiCategory: String) {
        self.title = title
        self.description = description
        self.iosPushType = iosPushType
        self.ignoreIOSBadge = ignoreIOSBadge
        self.iOSSound = iOSSound
        self.androidSound = androidSound
        self.androidVIVOClassification = androidVIVOClassification
        self.androidHuaWeiCategory = androidHuaWeiCategory
    }
}

public protocol CallLoader {
    func call(with request: CallLoaderRequest, completion: @escaping (Swift.Result<Void, Error>) -> Void)
}
