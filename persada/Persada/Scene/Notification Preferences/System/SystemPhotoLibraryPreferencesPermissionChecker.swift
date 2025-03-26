//
//  SystemPhotoLibraryPreferencesPermissionChecker.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import Photos

class SystemPhotoLibraryPreferencesPermissionChecker: PhotoLibraryPreferencesPermissionChecker {
        
    typealias Result = PhotoLibraryPreferencesPermissionChecker.Result
    
    init() {}
    
    func check(completion: @escaping (Result) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] permission in
            guard self != nil else { return }
            switch permission {
            case .authorized:
                completion(PhotoLibraryPreferencesPermissionCheckerItem(isPermissionAllowed: true))
            default:
                completion(PhotoLibraryPreferencesPermissionCheckerItem(isPermissionAllowed: false))
            }
        }
    }
}
