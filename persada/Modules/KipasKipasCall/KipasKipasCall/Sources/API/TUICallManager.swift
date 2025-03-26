//
//  TUICallManager.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/24.
//

import Foundation
import KipasKipasNetworking
import TUICallKit_Swift
import TUICallEngine

class TUICallManager: NSObject {
    private static var _selfInstance: TUICallManager?
    private static var _instance: TUICallKit?
    private static let engineInstance = TUICallEngine.createInstance()
    private static let lock = NSLock()
    
    var authRequest: TUICallLoginAuthenticatorRequest?
    
    static var instance: TUICallKit {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = TUICallKit.createInstance()
                _instance?.enableFloatWindow(enable: true)
                engineInstance.addObserver(selfInstance)
            }
        }
        return _instance!
    }
    
    static var selfInstance: TUICallManager {
        if _selfInstance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _selfInstance == nil {
                _selfInstance = TUICallManager()
            }
        }
        return _selfInstance!
    }
    
    private override init() {}
    
    func mapError(code: Int32, message: String?) -> KKNetworkError {
        return KKNetworkError.responseFailure(.init(code: "\(Int(code))", message: message ?? "Unknown Error"))
    }
    
    static func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallStateViewModel.shared.updateState(.calling)
        NotificationCenter.default.post(name: .init("callStart"), object: nil)
        TUICallManager.instance.call(userId: userId, callMediaType: callMediaType, params: params, succ: succ, fail: fail)
    }
    
    static func ignoreCall() {
        engineInstance.ignore {
            print("ignore call success")
        } fail: { code, message in
            print("ignore call failure (\(code)-\(String(describing: message)))")
        }
    }
}

extension TUICallManager: TUICallObserver {
    func onCallReceived(callerId: String, calleeIdList: [String], groupId: String?, callMediaType: TUICallMediaType, userData: String?) {
        guard TUICallStateViewModel.shared.isLiving == false else {
            TUICallManager.ignoreCall()
            return
        }
        
        TUICallStateViewModel.shared.updateState(.waiting)
        NotificationCenter.default.post(name: .init("callReceived"), object: nil)
    }
    
    func onCallCancelled(callerId: String) {
        TUICallStateViewModel.shared.updateState(.notOnCall)
        NotificationCenter.default.post(name: .init("callCancelled"), object: nil)
    }
    
    func onCallBegin(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole) {
        TUICallStateViewModel.shared.updateState(.onCall)
        NotificationCenter.default.post(name: .init("callBegin"), object: nil)
    }
    
    func onCallEnd(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole, totalTime: Float) {
        TUICallStateViewModel.shared.updateState(.notOnCall)
        NotificationCenter.default.post(name: .init("callEnd"), object: nil)
    }
}
