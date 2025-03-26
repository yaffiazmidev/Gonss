//
//  SystemNotificationPreferencesPermissionChecker.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UserNotifications

class SystemNotificationPreferencesPermissionChecker: NotificationPreferencesPermissionChecker {
    
    private let notificationCenter: UNUserNotificationCenter
    
    typealias Result = NotificationPreferencesPermissionChecker.Result
    
    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }
    
    func check(completion: @escaping (Result) -> Void) {
        notificationCenter.getNotificationSettings { [weak self] permission in
            guard self != nil else { return }
            switch permission.authorizationStatus  {
            case .authorized:
                completion(NotificationPreferencesPermissionCheckerItem(isPermissionAllowed: true))
            default:
                completion(NotificationPreferencesPermissionCheckerItem(isPermissionAllowed: false))
            }
        }

    }
}
