//
//  TUICallLoader.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation
import KipasKipasShared
import TUICallEngine

public class TUICallLoader: CallLoader {
    
    public init() {}
    
    public func call(with request: CallLoaderRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let roomId = TUIRoomId()
        roomId.strRoomId = request.roomId
        
        
        let params = TUICallParams()
        params.timeout = Int32(request.timeOut)
        params.userData = "Tes"
        
        if let info = request.pushInfo {
            let pushInfo = TUIOfflinePushInfo()
            pushInfo.title = info.title
            pushInfo.desc = info.description
            // iOS push type: if you want user VoIP, please modify type to TUICallIOSOfflinePushTypeVoIP
            pushInfo.iOSPushType = info.iosPushType.tui
            pushInfo.ignoreIOSBadge = info.ignoreIOSBadge
            pushInfo.iOSSound = info.iOSSound
            pushInfo.androidSound = info.androidSound
            // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
            pushInfo.androidVIVOClassification = info.androidVIVOClassification
            // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
            pushInfo.androidHuaWeiCategory = info.androidHuaWeiCategory
            
            params.offlinePushInfo = pushInfo
        }
        
        TUICallManager.call(userId: request.userId, callMediaType: request.type.tui, params: params) {
            completion(.success(()))
        } fail: { code, message in
            completion(.failure(TUICallManager.selfInstance.mapError(code: code, message: message)))
        }
    }
}

fileprivate extension IOSCallPushType {
    var tui: TUICallIOSOfflinePushType {
        switch self {
        case .apns:
            return .apns
        case .voIP:
            return .voIP
        }
    }
}

fileprivate extension CallType {
    var tui: TUICallMediaType {
        switch self {
        case .audio: return .audio
        case .video: return .video
        }
    }
}

extension MainQueueDispatchDecorator: CallLoader where T == CallLoader {
    public func call(with request: CallLoaderRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        decoratee.call(with: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
