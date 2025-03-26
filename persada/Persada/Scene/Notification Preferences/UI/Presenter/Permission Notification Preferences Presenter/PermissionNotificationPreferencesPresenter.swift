//
//  PermissionNotificationPreferencesPresenter.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class PermissionNotificationPreferencesPresenter {
    private let successView: PermissionNotificationPreferencesView?
    
    init(
        successView: PermissionNotificationPreferencesView) {
        self.successView = successView
    }
    
    func didFinishCheckingPermission(with item: NotificationPreferencesPermissionCheckerItem) {
        successView?.display(PermissionNotificationPreferencesViewModels(item: item))
    }
}
