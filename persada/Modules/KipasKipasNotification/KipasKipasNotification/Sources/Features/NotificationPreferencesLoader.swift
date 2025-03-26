//
//  NotificationPreferencesLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation

public protocol NotificationPreferencesLoader {
    typealias ResultPreferences = Swift.Result<NotificationPreferencesItem, Error>
    
    func load(request: NotificationPreferencesRequest, completion: @escaping (ResultPreferences) -> Void)
}
