//
//  KKRuntimeEnvirontment.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/12/23.
//

import Foundation

public enum KKRuntimeEnvironmentType: String {
    case other
    case testflight
    case appstore
    
    public var code: String {
        switch self {
        case .other: return "IOS"
        case .testflight: return "TF"
        case .appstore: return "AS"
        }
    }
}

public class KKRuntimeEnvironment {
    
    private static var _instance: KKRuntimeEnvironment?
    private static let lock = NSLock()
    
    private var _type: KKRuntimeEnvironmentType?
    
    public static var instance: KKRuntimeEnvironment {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = KKRuntimeEnvironment()
            }
        }
        return _instance!
    }
    
    
    public var type: KKRuntimeEnvironmentType {
        if _type == nil {
            _type = decideType
        }
        
        return _type!
    }
    
    private init() {}
    
}

private extension KKRuntimeEnvironment {
    private var decideType: KKRuntimeEnvironmentType {
        #if targetEnvironment(simulator) || os(OSX) || targetEnvironment(macCatalyst)
        return .other
        #else
        
        // MobilePovision profiles are a clear indicator for Ad-Hoc distribution.
        if hasEmbeddedMobileProvision() {
            return .other
        }
        
        // TestFlight is only supported from iOS 8 onwards
        if isAppStoreReceiptSandbox() {
            return .testflight
        }
        
        return .appstore
        #endif
    }
    
    private func hasEmbeddedMobileProvision() -> Bool {
        let hasEmbeddedMobileProvision = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
        return hasEmbeddedMobileProvision
    }
    
    private func isAppStoreReceiptSandbox() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }
        
        let appStoreReceiptLastComponent = appStoreReceiptURL.lastPathComponent
        let isSandboxReceipt = appStoreReceiptLastComponent == "sandboxReceipt"
        
        return isSandboxReceipt
        #endif
    }
}
