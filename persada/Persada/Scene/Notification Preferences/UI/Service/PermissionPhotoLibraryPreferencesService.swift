//
//  PermissionPhotoLibraryPreferencesService.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class PermissionPhotoLibraryPreferencesService: PermissionPhotoLibraryPreferencesControllerDelegate {

    private let checker: PhotoLibraryPreferencesPermissionChecker
    var presenter: PermissionPhotoLibraryPreferencesPresenter?
    
    init(
        checker: PhotoLibraryPreferencesPermissionChecker
    ) {
        self.checker = checker
    }
    
    func didCheckPhotoLibraryPermissionStatus() {
        checker.check { [weak self] result in
            guard let self = self else { return }
            self.presenter?.didFinishCheckingPermission(with: result)
        }
    }
}
