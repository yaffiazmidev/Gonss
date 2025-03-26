//
//  NotificationPreferencesViewProtocols.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol NotificationPreferencesView {
    func display(_ viewModel: NotificationPreferencesViewModel)
}

protocol NotificationPreferencesLoadingView {
    func display(_ viewModel: NotificationPreferencesLoadingViewModel)
}

protocol NotificationPreferencesErrorView {
    func display(_ viewModel: NotificationPreferencesLoadingErrorViewModel)
}
