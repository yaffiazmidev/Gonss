//
//  NotificationPreferencesUpdater.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol NotificationPreferencesUpdater {
    typealias Result = Swift.Result<NotificationPreferencesUpdateItem, Error>
    
    func update(request: NotificationPreferencesUpdateRequest, completion: @escaping (Result) -> Void)
}
