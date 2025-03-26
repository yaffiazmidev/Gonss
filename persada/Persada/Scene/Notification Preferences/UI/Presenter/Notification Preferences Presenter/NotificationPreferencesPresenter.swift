//
//  NotificationPreferencesPresenter.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class NotificationPreferencesPresenter {
    private let successView: NotificationPreferencesView?
    private let loadingView: NotificationPreferencesLoadingView?
    private let errorView: NotificationPreferencesErrorView?
    
    init(
        successView: NotificationPreferencesView,
        loadingView: NotificationPreferencesLoadingView,
        errorView: NotificationPreferencesErrorView) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("NOTIFICATION_PREFERENCES_GET_ERROR",
                          tableName: "NotificationPreferences",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    
    func didStartLoadingGetNotificationPreferences() {
        errorView?.display(.noError)
        loadingView?.display(NotificationPreferencesLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetNotificationPreferences(with item: NotificationPreferencesItem) {
        successView?.display(NotificationPreferencesViewModel(item: item))
        loadingView?.display(NotificationPreferencesLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetNotificationPreferences(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(NotificationPreferencesLoadingViewModel(isLoading: false))
    }
}
