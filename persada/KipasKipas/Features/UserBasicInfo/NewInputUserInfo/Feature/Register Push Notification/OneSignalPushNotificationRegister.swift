//
//  OneSignalPushNotificationRegister.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import OneSignal

class OneSignalPushNotificationRegister: PushNotificationRegister {
    
    func register(request: PushNotificationRegisterRequest) {
        OneSignal.setExternalUserId(request.accountlID) { results in
            print("External user id update complete with results: ", results!.description)
        } withFailure: { print($0 ?? "") }
    }
}
