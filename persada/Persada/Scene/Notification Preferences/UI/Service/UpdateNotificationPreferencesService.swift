//
//  UpdateNotificationPreferencesService.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class UpdateNotificationPreferencesService: UpdateNotificationPreferencesControllerDelegate {
    
    private let updater: NotificationPreferencesUpdater
    var presenter: UpdateNotificationPreferencesPresenter?
    
    init(
        updater: NotificationPreferencesUpdater
    ) {
        self.updater = updater
    }
    
    func didUpdateNotificationPreferences(request: NotificationPreferencesUpdateRequest, for type: NotificationPreferencesType) {
        presenter?.didStartLoadingUpdateNotificationPreferences()
        updater.update(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(updateItem):
                self.presenter?.didFinishLoadingUpdateNotificationPreferences(with: updateItem)
            case let .failure(error):
                self.presenter?.didFinishLoadingUpdateNotificationPreferences(with: error, for: type)
            }
        }
    }
}
