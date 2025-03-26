//
//  NotificationPreferencesUpdater.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation

public protocol NotificationPreferencesUpdater {
    typealias Result = Swift.Result<NotificationPreferencesUpdateItem, Error>
    
    func update(request: NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void)
}
