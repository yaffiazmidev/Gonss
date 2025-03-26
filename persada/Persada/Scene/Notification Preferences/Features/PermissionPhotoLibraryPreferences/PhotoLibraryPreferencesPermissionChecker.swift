//
//  PhotoLibraryPreferencesPermissionChecker.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol PhotoLibraryPreferencesPermissionChecker {
    typealias Result = PhotoLibraryPreferencesPermissionCheckerItem
    
    func check(completion: @escaping (Result) -> Void)
}
