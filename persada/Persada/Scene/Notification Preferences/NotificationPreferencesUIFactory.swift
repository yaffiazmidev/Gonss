//
//  NotificationPreferencesUIFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UserNotifications

final class NotificationPreferencesUIFactory {
    
    static func create() -> NotificationPreferencesViewController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let loader = RemoteNotificationPreferencesLoader(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        let updater = RemoteNotificationPreferencesUpdater(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        let checker = SystemNotificationPreferencesPermissionChecker(notificationCenter: UNUserNotificationCenter.current())
        let photoLibraryChecker = SystemPhotoLibraryPreferencesPermissionChecker()

        let controller = NotificationPreferencesUIComposer.notificationPreferencesComposedWith(loader: loader, updater: updater, checker: checker, photoLibraryChecker: photoLibraryChecker)
        return controller
    }
}
