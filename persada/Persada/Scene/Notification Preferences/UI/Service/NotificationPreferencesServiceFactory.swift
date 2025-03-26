//
//  NotificationPreferencesServiceFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class NotificationPreferencesServiceFactory: NotificationPreferencesDelegate {

    private let loader: NotificationPreferencesViewControllerDelegate
    private let updater: UpdateNotificationPreferencesControllerDelegate
    private let checker: PermissionNotificationPreferencesControllerDelegate
    private let photoLibraryChecker: PermissionPhotoLibraryPreferencesControllerDelegate
  
    init(
        loader: NotificationPreferencesViewControllerDelegate,
        updater: UpdateNotificationPreferencesControllerDelegate,
        checker: PermissionNotificationPreferencesControllerDelegate,
        photoLibraryChecker: PermissionPhotoLibraryPreferencesControllerDelegate
    ) {
        self.loader = loader
        self.updater = updater
        self.checker = checker
        self.photoLibraryChecker = photoLibraryChecker
    }
    
    func didRequestNotificationPreferences(request: NotificationPreferencesRequest) {
        loader.didRequestNotificationPreferences(request: request)
    }
    
    func didUpdateNotificationPreferences(request: NotificationPreferencesUpdateRequest, for type: NotificationPreferencesType) {
        updater.didUpdateNotificationPreferences(request: request, for: type)
    }
    
    func didCheckNotificationPermissionStatus() {
        checker.didCheckNotificationPermissionStatus()
    }
    
    func didCheckPhotoLibraryPermissionStatus() {
        photoLibraryChecker.didCheckPhotoLibraryPermissionStatus()
    }
}
