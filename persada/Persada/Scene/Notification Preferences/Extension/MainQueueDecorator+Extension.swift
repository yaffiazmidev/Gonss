//
//  MainQueueDecorator+Extension.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: NotificationPreferencesLoader where T == NotificationPreferencesLoader {
    func load(request: NotificationPreferencesRequest, completion: @escaping (NotificationPreferencesLoader.Result) -> Void) {
        decoratee.load(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationPreferencesUpdater where T == NotificationPreferencesUpdater {
    
    func update(request: NotificationPreferencesUpdateRequest, completion: @escaping (NotificationPreferencesUpdater.Result) -> Void) {
        decoratee.update(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NotificationPreferencesPermissionChecker where T == NotificationPreferencesPermissionChecker {
    
    func check(completion: @escaping (NotificationPreferencesPermissionChecker.Result) -> Void) {
        decoratee.check  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: PhotoLibraryPreferencesPermissionChecker where T == PhotoLibraryPreferencesPermissionChecker {
    
    func check(completion: @escaping (PhotoLibraryPreferencesPermissionChecker.Result) -> Void) {
        decoratee.check  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
