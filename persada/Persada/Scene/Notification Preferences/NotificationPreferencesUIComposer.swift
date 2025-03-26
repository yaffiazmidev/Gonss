//
//  NotificationPreferencesComposer.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class NotificationPreferencesUIComposer {
    private init() {}
    
    public static func notificationPreferencesComposedWith(
        loader: NotificationPreferencesLoader,
        updater: NotificationPreferencesUpdater,
        checker: NotificationPreferencesPermissionChecker,
        photoLibraryChecker: PhotoLibraryPreferencesPermissionChecker) -> NotificationPreferencesViewController {
            
            let loaderService = NotificationPreferencesService(loader: MainQueueDispatchDecorator(decoratee: loader))
            let updaterService = UpdateNotificationPreferencesService(updater: MainQueueDispatchDecorator(decoratee: updater))
            let checkerService = PermissionNotificationPreferencesService(checker: MainQueueDispatchDecorator(decoratee: checker))
            let photoLibraryCheckerService = PermissionPhotoLibraryPreferencesService(checker: MainQueueDispatchDecorator(decoratee: photoLibraryChecker))
            
            let serviceFactory = NotificationPreferencesServiceFactory(
                loader: loaderService,
                updater: updaterService,
                checker: checkerService,
                photoLibraryChecker: photoLibraryCheckerService)
            
            let controller = NotificationPreferencesViewController(delegate: serviceFactory)
            
            loaderService.presenter = NotificationPreferencesPresenter(
                successView: WeakRefVirtualProxy(controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller))
            updaterService.presenter = UpdateNotificationPreferencesPresenter(
                successView: WeakRefVirtualProxy(controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller))
            checkerService.presenter = PermissionNotificationPreferencesPresenter(successView: WeakRefVirtualProxy(controller))
            photoLibraryCheckerService.presenter = PermissionPhotoLibraryPreferencesPresenter(successView: WeakRefVirtualProxy(controller))
            
            return controller
        }
}
