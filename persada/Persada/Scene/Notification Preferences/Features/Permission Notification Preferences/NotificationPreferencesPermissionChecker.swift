//
//  NotificationPreferencesPermissionChecker.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol NotificationPreferencesPermissionChecker {
    typealias Result = NotificationPreferencesPermissionCheckerItem
    
    func check(completion: @escaping (Result) -> Void)
}
