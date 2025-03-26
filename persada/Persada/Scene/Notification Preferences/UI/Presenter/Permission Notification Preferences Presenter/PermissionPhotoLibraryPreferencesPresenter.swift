//
//  PermissionPhotoLibraryPreferencesPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class PermissionPhotoLibraryPreferencesPresenter {
    private let successView: PermissionPhotoLibraryPreferencesView?
    
    init(
        successView: PermissionPhotoLibraryPreferencesView) {
        self.successView = successView
    }
    
    func didFinishCheckingPermission(with item: PhotoLibraryPreferencesPermissionCheckerItem) {
        successView?.display(PermissionPhotoLibraryPreferencesViewModels(item: item))
    }
}
