//
//  NotificationPreferencesService.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class NotificationPreferencesService: NotificationPreferencesViewControllerDelegate {
    
    private let loader: NotificationPreferencesLoader
    var presenter: NotificationPreferencesPresenter?
    
    init(
        loader: NotificationPreferencesLoader
    ) {
        self.loader = loader
    }
    
    func didRequestNotificationPreferences(request: NotificationPreferencesRequest) {
        presenter?.didStartLoadingGetNotificationPreferences()
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(notificationPreferencesItem):
                self.presenter?.didFinishLoadingGetNotificationPreferences(with: notificationPreferencesItem)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetNotificationPreferences(with: error)
            }
        }
    }
}
