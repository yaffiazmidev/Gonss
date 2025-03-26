//
//  NotificationPreferencesLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol NotificationPreferencesLoader {
    typealias Result = Swift.Result<NotificationPreferencesItem, Error>
    
    func load(request: NotificationPreferencesRequest, completion: @escaping (Result) -> Void)
}
