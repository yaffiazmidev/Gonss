//
//  WeakRefVirtualProxy+Extension.swift
//  KipasKipas
//
//  Created by PT.Koanba on 16/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Permission
extension WeakRefVirtualProxy: PermissionNotificationPreferencesView where T: PermissionNotificationPreferencesView {
    
    func display(_ viewModel: PermissionNotificationPreferencesViewModels) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PermissionPhotoLibraryPreferencesView where T: PermissionPhotoLibraryPreferencesView {
    
    func display(_ viewModel: PermissionPhotoLibraryPreferencesViewModels) {
        object?.display(viewModel)
    }
}

// MARK: Update
extension WeakRefVirtualProxy: UpdateNotificationPreferencesView where T: UpdateNotificationPreferencesView {
    
    func display(_ viewModel: UpdateNotificationPreferencesViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UpdateNotificationPreferencesLoadingView where T: UpdateNotificationPreferencesLoadingView {
    
    func display(_ viewModel: UpdateNotificationPreferencesLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: UpdateNotificationPreferencesErrorView where T: UpdateNotificationPreferencesErrorView {
    
    func display(_ viewModel: UpdateNotificationPreferencesLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

// MARK: Get
extension WeakRefVirtualProxy: NotificationPreferencesView where T: NotificationPreferencesView {
    
    func display(_ viewModel: NotificationPreferencesViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationPreferencesLoadingView where T: NotificationPreferencesLoadingView {
    
    func display(_ viewModel: NotificationPreferencesLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NotificationPreferencesErrorView where T: NotificationPreferencesErrorView {
    
    func display(_ viewModel: NotificationPreferencesLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}

