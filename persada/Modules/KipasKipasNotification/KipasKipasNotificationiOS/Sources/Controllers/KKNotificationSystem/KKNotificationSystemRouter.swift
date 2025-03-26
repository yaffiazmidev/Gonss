//
//  KKNotificationSystemRouter.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 26/04/24.
//

import Foundation
import KipasKipasNotification

protocol IKKNotificationSystemRouter {
    func navigateToNotificationContents(by types: String)
    func navigateToSystemSetting()
}

class KKNotificationSystemRouter: IKKNotificationSystemRouter {
    
    weak var controller: KKNotificationSystemController?
    private var systemNotifLoader: NotificationSystemLoader
    private let preferencesLoader: NotificationPreferencesLoader
    private let preferencesUpdater: NotificationPreferencesUpdater
    
    init(
        systemNotifLoader: NotificationSystemLoader,
        preferencesLoader: NotificationPreferencesLoader,
        preferencesUpdater: NotificationPreferencesUpdater
    ) {
        self.systemNotifLoader = systemNotifLoader
        self.preferencesLoader = preferencesLoader
        self.preferencesUpdater = preferencesUpdater
    }
    
    func navigateToNotificationContents(by types: String) {
        let viewModel = KKNotificationContentSystemViewModel(systemNotifLoader: systemNotifLoader)
        viewModel.types = types
        let vc = KKNotificationContentSystemController(viewModel: viewModel)
        viewModel.delegate = vc
        vc.showFeed = controller?.showFeed
        vc.showLive = controller?.showLive
        controller?.push(vc)
    }
    
    func navigateToSystemSetting() {
        let vc = NotificationSystemSettingController(preferencesLoader: preferencesLoader, preferencesUpdater: preferencesUpdater)
        vc.modalPresentationStyle = .overFullScreen
        controller?.push(vc)
    }
}
