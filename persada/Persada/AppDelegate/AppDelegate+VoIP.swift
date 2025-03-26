//
//  AppDelegate+VoIP.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import TUICallKitVoIPExtension
import KipasKipasShared

extension AppDelegate {
    func configureVoIP() {
        let id: Int
        if KKRuntimeEnvironment.instance.type == .other {
            id = 15881
        } else {
            id = 15880
        }
        
        if KKCache.common.readBool(key: .enablePushCall) ?? true {
            TUICallKitVoIPExtension.setCertificateID(id)
        }
    }
    
    func continueVoIP(userActivity: NSUserActivity) {
        TUICallKitVoIPExtension.call(with: userActivity)
    }
}
