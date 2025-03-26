//
//  NotificationPreferencesDelegate.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol NotificationPreferencesViewControllerDelegate {
    func didRequestNotificationPreferences(request: NotificationPreferencesRequest)
}

protocol UpdateNotificationPreferencesControllerDelegate {
    func didUpdateNotificationPreferences(request: NotificationPreferencesUpdateRequest, for type: NotificationPreferencesType)
}

protocol PermissionNotificationPreferencesControllerDelegate {
    func didCheckNotificationPermissionStatus()
}

protocol PermissionPhotoLibraryPreferencesControllerDelegate {
    func didCheckPhotoLibraryPermissionStatus()
}

typealias NotificationPreferencesDelegate = NotificationPreferencesViewControllerDelegate & UpdateNotificationPreferencesControllerDelegate & PermissionNotificationPreferencesControllerDelegate & PermissionPhotoLibraryPreferencesControllerDelegate
