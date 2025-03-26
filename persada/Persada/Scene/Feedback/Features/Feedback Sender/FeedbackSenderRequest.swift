//
//  FeedbackSenderRequest.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

struct FeedbackSenderRequest: Encodable {
    let message: String
    let deviceType: String
    let devicePlatform: String?
    let deviceModel: String?
    let appVersion: String
    
    init(message: String, deviceType: String, devicePlatform: String?, deviceModel: String?, appVersion: String) {
        self.message = message
        self.deviceType = deviceType
        self.devicePlatform = devicePlatform
        self.deviceModel = deviceModel
        self.appVersion = appVersion
    }
    
    static func create(with message: String) -> FeedbackSenderRequest {
        let request = FeedbackSenderRequest(
            message: message,
            deviceType: "IOS",
            devicePlatform: UIDevice.current.systemVersion,
            deviceModel: getDeviceModel(),
            appVersion: getAppVersion())
        return request
    }
    
    private static func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "0.0.0"
        }
        return version
    }
    
    private static func getDeviceModel() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) 
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
}
