//
//  UpdateNotificationPreferencesPresenter.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class UpdateNotificationPreferencesPresenter {
    private let successView: UpdateNotificationPreferencesView?
    private let loadingView: UpdateNotificationPreferencesLoadingView?
    private let errorView: UpdateNotificationPreferencesErrorView?
    
    init(
        successView: UpdateNotificationPreferencesView,
        loadingView: UpdateNotificationPreferencesLoadingView,
        errorView: UpdateNotificationPreferencesErrorView) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var updateError: String {
        NSLocalizedString("NOTIFICATION_PREFERENCES_UPDATE_ERROR",
                          tableName: "NotificationPreferences",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't update notification preferences to the server")
    }
    
    func didStartLoadingUpdateNotificationPreferences() {
        errorView?.display(.noError)
        loadingView?.display(UpdateNotificationPreferencesLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingUpdateNotificationPreferences(with item: NotificationPreferencesUpdateItem) {
        successView?.display(UpdateNotificationPreferencesViewModel(item: item))
        loadingView?.display(UpdateNotificationPreferencesLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingUpdateNotificationPreferences(with error: Error, for type: NotificationPreferencesType) {
        errorView?.display(.error(message: Self.updateError, type: type))
        loadingView?.display(UpdateNotificationPreferencesLoadingViewModel(isLoading: false))
    }
}
