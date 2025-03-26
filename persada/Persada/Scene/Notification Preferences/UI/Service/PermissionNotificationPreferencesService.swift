//
//  PermissionNotificationPreferencesService.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UserNotifications

class PermissionNotificationPreferencesService: PermissionNotificationPreferencesControllerDelegate {

    private let checker: NotificationPreferencesPermissionChecker
    var presenter: PermissionNotificationPreferencesPresenter?
    let current = UNUserNotificationCenter.current()

    init(
        checker: NotificationPreferencesPermissionChecker
    ) {
        self.checker = checker
    }
    
    func didCheckNotificationPermissionStatus() {
        checker.check { [weak self] result in
            guard let self = self else { return }
            self.presenter?.didFinishCheckingPermission(with: result)
        }
    }
}
