//
//  SendbirdSDKEnvUseCase.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 03/08/23.
//

import Foundation
import SendbirdChatSDK

public class SendbirdSDKEnvUseCase {
    
    private init() {}
    
    public static func initialize(appId: String) {
        let initParams = InitParams(
            applicationId: appId,
            isLocalCachingEnabled: true,
            logLevel: .error,
            appVersion: "1.0.0"
        )
        SendbirdChat.initialize(params: initParams)
    }
}
